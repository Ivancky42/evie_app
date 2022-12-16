import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/page_widget/home_page_widet_change_bike_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';

class Bike_Name_Row extends StatelessWidget {
  String bikeName;
  String distanceBetween;
  String currentBikeStatusImage;
bool isDeviceConnected;

  Bike_Name_Row({
    Key? key,
    required this.bikeName,
    required this.distanceBetween,
    required this.currentBikeStatusImage,
    required this.isDeviceConnected,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  bikeName,
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
                SvgPicture.asset(
                  "assets/icons/batch_tick.svg",
                  width: 20.w,
                  height: 20.h,
                ),
                SvgPicture.asset(
                  "assets/icons/connection.svg",
                  width: 20.w,
                  height: 20.h,
                ),
              ],
            ),
            SizedBox(
              height: 4.h,
            ),
            Text(
              "Est. ${distanceBetween}m",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        GestureDetector(
          onTap: (){
            showMaterialModalBottomSheet(
                expand: false,
                context: context,
                builder: (context) {
                  return ChangeBikeBottomSheet();
                });
          },
          child: Image(
            image: AssetImage(currentBikeStatusImage),
            height: 60.h,
            width: 87.w,
          ),
        ),
      ],
    );
  }
}

class Bike_Status_Row extends StatelessWidget {
  String currentSecurityIcon;
  Widget child;
  String batteryImage;
  int batteryPercentage;

  Bike_Status_Row({
    Key? key,
    required this.currentSecurityIcon,
    required this.child,
    required this.batteryImage,
    required this.batteryPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [

         SvgPicture.asset(
          currentSecurityIcon,
          height:36.h,
           width: 36.w,
        ),
      SizedBox(width: 4.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 135.w,
            child: child,
          )
        ],
      ),
      const VerticalDivider(
        thickness: 1,
      ),
      SvgPicture.asset(
        batteryImage,
        width: 36.w,
        height: 36.h,
      ),
      SizedBox(
        width: 10.w,
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "${batteryPercentage} %",
          style: TextStyle(fontSize: 20.sp),
        ),
        Text(
          "Est 0km",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        )
      ])
    ]);
  }
}


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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEDEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 28.h,
          ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                EdgeInsets.only(left: 17.w),
                child: Text(
                  "Threat History",
                  style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight:
                      FontWeight.w500),
                ),
              ),
              IconButton(
                onPressed: () {

                },
                icon: SvgPicture.asset(
                  "assets/buttons/filter.svg",
                ),
              ),
            ],
          ),
          SizedBox(
            height: 11.h,
          ),
          const Divider(
            thickness: 2,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Container(
                  height:504.h,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: PaginateFirestore(
                      // Use SliverAppBar in header to make it sticky
                      footer:SliverToBoxAdapter(
                        child:  Center(
                        child: Text(
                          "scroll to load more",
                          style: TextStyle(
                              color: Color(0xff7A7A79),
                              fontSize: 12.sp),
                        ),
                      ),),
                      // item builder type is compulsory.
                      itemBuilderType:
                      PaginateBuilderType.listView, //Change types accordingly
                      itemBuilder: (context, documentSnapshots, index) {
                        final data = documentSnapshots[index].data() as Map?;
                        return ListTile(
                          leading: data == null
                              ? const Text('Error')
                              : SvgPicture.asset(
                            getSecurityTextWidget(data['type']),
                            height: 36.h,
                            width: 36.w,
                          ),
                          title: data == null
                              ? const Text('Error in data')
                              : Text(data['type']),
                          subtitle: Text(documentSnapshots[index].id),
                        );
                      },
                      // orderBy is compulsory to enable pagination
                      query: FirebaseFirestore.instance.collection('bikes').doc(widget.bikeProvider.currentBikeIMEI).collection("events").orderBy('created'),
                      itemsPerPage: 5,
                      // to fetch real-time data
                      isLive: true,
                    ),
                  ),
                ),

                SizedBox(height: 1.h),
                Padding(
                  padding:
                  const EdgeInsets.all(6),
                  child: Container(
                    child: ElevatedButton(
                      child: Text(
                        "Show All Data",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:
                          Color(0xff7A7A79),
                        ),
                      ),
                      onPressed: () {},
                      style: ElevatedButton
                          .styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                14.0),
                            side: const BorderSide(
                                color: Color(
                                    0xff7A7A79))),
                        elevation: 0.0,
                        backgroundColor:
                        Colors.transparent,
                        padding: const EdgeInsets
                            .symmetric(
                            horizontal: 120,
                            vertical: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      height: 720.h,
    );
  }

  getSecurityTextWidget(String eventType) {
    switch (eventType) {
      case "warning":
        return "assets/buttons/bike_security_warning.svg";
      case "danger":
        return "assets/buttons/bike_security_danger.svg";
      case "lock":
        return "assets/buttons/bike_security_lock_and_secure.svg";
      case "unlock":
        return "assets/buttons/bike_security_unlock.svg";
      default:
        return "assets/buttons/bike_security_not_available.svg";
    }
  }
}
