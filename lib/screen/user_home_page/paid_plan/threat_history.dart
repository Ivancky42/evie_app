
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../../api/colours.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../widgets/evie_radio_button.dart';
import '../../../widgets/evie_switch.dart';

class Threat_History extends StatefulWidget {
  BikeProvider bikeProvider;
  BluetoothProvider bluetoothProvider;
  LocationProvider locationProvider;


  Threat_History({
    Key? key,
    required this.bikeProvider,
    required this.bluetoothProvider,
    required this.locationProvider,

  }) : super(key: key);

  @override
  State<Threat_History> createState() => _Threat_HistoryState();
}

class _Threat_HistoryState extends State<Threat_History> {

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEDEB),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding:  EdgeInsets.only(top: 13.h),
            child: SvgPicture.asset(
              "assets/buttons/down.svg",
            ),
          ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [

              Padding(
                padding:
                EdgeInsets.only(left: 17.w, top: 10.h, bottom: 11.h),
                child: Text(
                  "Threat History",
                  style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight:
                      FontWeight.w500),
                ),
              ),
              Padding(
                padding: EdgeInsets.only( top: 38.h,),
                child: IconButton(
                  onPressed: () {



                    ///Open filter dialog
                    showFilterTreat(context);


                  },
                  icon: SvgPicture.asset(
                    "assets/buttons/filter.svg",
                  ),
                ),
              ),
            ],
          ),

          const Divider(
            thickness: 2,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              children: [
                Container(
                  height:504.h,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: RefreshIndicator(
                      child: PaginateFirestore(
                        // Use SliverAppBar in header to make it sticky
                        footer:SliverToBoxAdapter(
                          child:  Center(
                            child: Text(
                              "scroll to load more",
                              style: TextStyle(
                                  color: const Color(0xff7A7A79),
                                  fontSize: 12.sp),
                            ),
                          ),),
                        // item builder type is compulsory.
                        itemBuilderType: PaginateBuilderType.listView, //Change types accordingly
                        itemBuilder: (context, documentSnapshots, index) {
                          final data = documentSnapshots[index].data() as Map?;

                          ///Filter String
                           snapshotLength = data?.length;

                          return Column(
                            children: [
                              ListTile(
                                  leading: data == null
                                      ? const Text('Error')
                                      : SvgPicture.asset(
                                    getSecurityIconWidget(data['type']),
                                    height: 36.h,
                                    width: 36.w,
                                  ),
                                  title: data == null
                                      ? const Text('Error')
                                      : data["address"] != null
                                      ? Text(data["address"], style: TextStyle(fontSize: 18.sp),)
                                      : FutureBuilder<dynamic>(
                                      future: widget.locationProvider.returnPlaceMarks(data["geopoint"].latitude, data["geopoint"].longitude),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          widget.bikeProvider.uploadPlaceMarkAddressToFirestore(widget.bikeProvider.currentBikeModel!.deviceIMEI!, documentSnapshots[index].id,  snapshot.data.name.toString());
                                          return Text(
                                            snapshot.data.name.toString(),
                                            style: TextStyle(fontSize: 18.sp),
                                          );
                                        }else{
                                          return const Text(
                                            "loading",
                                          );
                                        }
                                      }
                                  ),
                                  subtitle: data == null
                                      ? const Text('Error in data')
                                      : Text("${getSecurityTextWidget(data["type"])} • ${data["created"]!.toDate().toString()}", style: TextStyle(fontSize: 12.sp),)

                              ),
                              const Divider(height: 1),
                            ],
                          );
                        },
                        // orderBy is compulsory to enable pagination
                        query: FirebaseFirestore.instance.collection("bikes")
                              .doc(widget.bikeProvider.currentBikeModel!.deviceIMEI!)
                              .collection("events")
                              //.where("string", isEqualTo:"some string")
                              //.where("created", isGreaterThanOrEqualTo: fromDate)
                              //.where("created", isLessThanOrEqualTo: endDate)
                              .orderBy("created", descending: true),

                        itemsPerPage: snapshotLength ?? 10,
                        // to fetch real-time data
                        isLive: false,
                        listeners: [
                          refreshChangeListener,
                        ],
                      ),
                      onRefresh: () async {
                        refreshChangeListener.refreshed = true;
                      },
                    ),
                  ),
                ),

                SizedBox(height: 1.h),
                Padding(
                  padding:
                  const EdgeInsets.all(6),
                  child:  Padding(
                    padding: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 0.h, bottom: 6.h),
                    child: Container(
                      height: 45.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(
                          "Show All Data",
                          style: TextStyle(
                              fontSize: 17.sp,
                              color: Color(0xff7A7A79),
                              fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side:  BorderSide(color: Color(0xff7A7A79), width: 1.5.w)),
                          elevation: 0.0,
                          backgroundColor: Colors.transparent,

                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      height: 750.h,
    );
  }

  getSecurityIconWidget(String eventType) {
    switch (eventType) {
      case "warning":
        return "assets/buttons/bike_security_warning.svg";
      case "danger":
        return "assets/buttons/bike_security_danger.svg";
      case "lock":
        return "assets/buttons/bike_security_lock_and_secure.svg";
      case "unlock":
        return "assets/buttons/bike_security_unlock.svg";
      case "fall":
        return "assets/buttons/bike_security_warning.svg";
      default:
        return "assets/buttons/bike_security_not_available.svg";
    }
  }

  getSecurityTextWidget(String eventType) {
    switch (eventType) {
      case "warning":
        return "Movement Detected";
      case "danger":
        return "Under threat";
      case "lock":
        return "Lock bike";
      case "unlock":
        return "Unlock bike";
      case "fall":
        return "Fall detection";
      default:
        return "empty";
    }
  }
}
