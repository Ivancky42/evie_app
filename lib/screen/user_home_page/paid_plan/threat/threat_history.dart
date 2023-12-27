import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';

import '../../../../api/attach.dart';
import '../../../../api/colours.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../../../api/provider/setting_provider.dart';
import '../../../../widgets/evie_radio_button.dart';
import '../../../../widgets/evie_switch.dart';

class ThreatHistory extends StatefulWidget {


  ThreatHistory({Key? key}) : super(key: key);

  @override
  State<ThreatHistory> createState() => _ThreatHistoryState();
}

class _ThreatHistoryState extends State<ThreatHistory> {
  
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late SettingProvider _settingProvider;

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  bool isPickedStatusExpand = false;
  bool isPickedDateExpand = false;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        color: EvieColors.grayishWhite,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 17.w, top: 0.h, bottom: 0.h),
                child: Text(
                  "EV-Secure",
                  style: EvieTextStyles.h1,
                ),
              ),

              Padding(
                padding: EdgeInsets.all(0),
                child: IconButton(
                  onPressed: () {
                    _locationProvider.locations();
                    _settingProvider.changeSheetElement(SheetList.mapDetails);
                  },
                  icon: SvgPicture.asset(
                    "assets/buttons/list_selected.svg",
                    width: 36.w,
                    height: 36.w,
                  ),
                ),
              ),
            ],
          ),

          const Divider(
            thickness: 0.5,
            color: EvieColors.darkWhite,
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Visibility(
                  visible: _bikeProvider.threatFilterDate != ThreatFilterDate.all || _bikeProvider.threatFilterArray.length != 4,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 0.w),
                    child: Container(
                      height: 33.h,
                      width: 46.w,
                      padding: EdgeInsets.zero,
                      child: ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "x",
                              style: EvieTextStyles.ctaSmall.copyWith(color: EvieColors.darkGrayish),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          _bikeProvider.applyThreatFilterDate(ThreatFilterDate.all, DateTime.now(), DateTime.now());

                          List<String> filter = ["warning","fall","danger","crash"];
                          await _bikeProvider.applyThreatFilterStatus(filter);

                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side:  BorderSide(color: EvieColors.darkGray, width: 1.0.w)),
                          elevation: 0.0,
                          backgroundColor: EvieColors.transparent,

                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: Container(
                    height: 33.h,
                    width: 110.w,
                    padding: EdgeInsets.zero,
                    child: ElevatedButton(
                      child: _bikeProvider.threatFilterArray.length == 4 ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Status",
                            style: EvieTextStyles.ctaSmall.copyWith(color: EvieColors.darkGray),
                          ),
                          SvgPicture.asset(
                            "assets/buttons/down_mini_bold.svg",
                          ),
                        ],
                      ) :

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_bikeProvider.threatFilterArray.length} Status",
                            style: EvieTextStyles.ctaSmall.copyWith(color: _bikeProvider.threatFilterArray.length == 4 ? EvieColors.darkGray : EvieColors.dividerWhite),
                          ),
                          SvgPicture.asset(
                            "assets/buttons/down_mini_bold_white.svg",
                          ),
                        ],
                      ),
                      onPressed: () async {
                        setState(() {
                          isPickedStatusExpand = true;
                        });
                      showFilterTreatStatus(context, _bikeProvider, isPickedStatusExpand ,setState);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side:  _bikeProvider.threatFilterArray.length == 4 ? BorderSide(color: EvieColors.darkGray, width: 1.0.w) : BorderSide(color: EvieColors.transparent,width: 0)),
                        elevation: 0.0,
                        backgroundColor: _bikeProvider.threatFilterArray.length == 4 ? EvieColors.transparent : EvieColors.lightGrayish,

                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0.w, right: 12.w),
                  child: Container(
                    height: 33.h,
                    width: 90.w,
                    padding: EdgeInsets.zero,
                    child: ElevatedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Date",
                            style: EvieTextStyles.ctaSmall.copyWith(color: _bikeProvider.threatFilterDate == ThreatFilterDate.all ? EvieColors.darkGray : EvieColors.dividerWhite),
                          ),
                          SvgPicture.asset(
                            _bikeProvider.threatFilterDate == ThreatFilterDate.all ? "assets/buttons/down_mini_bold.svg" : "assets/buttons/down_mini_bold_white.svg",
                          ),
                        ],
                      ),
                      onPressed: () async {
                        setState(() {
                          isPickedDateExpand = true;
                        });
                        showFilterTreatDate(context, _bikeProvider, isPickedDateExpand ,setState);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side:  _bikeProvider.threatFilterDate == ThreatFilterDate.all ? BorderSide(color: EvieColors.darkGray, width: 1.0.w) : BorderSide(color: EvieColors.transparent,width: 0)),
                        elevation: 0.0,
                        backgroundColor: _bikeProvider.threatFilterDate == ThreatFilterDate.all ? EvieColors.transparent : EvieColors.lightGrayish,

                      ),
                    ),
                  ),
                ),
            ],),
          ),



          Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              children: [
                Container(
                  height:576.h,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: RefreshIndicator(
                      child: PaginateFirestore(
                        // Use SliverAppBar in header to make it sticky
                        footer:SliverToBoxAdapter(
                          child:  Center(
                            child: Text(
                              "scroll to load more",
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayish),
                            ),
                          ),),
                        // item builder type is compulsory.
                        itemBuilderType: PaginateBuilderType.listView, //Change types accordingly
                        itemBuilder: (context, documentSnapshots, index) {
                          final data = documentSnapshots[index].data() as Map?;

                          ///Filter String
                           snapshotLength = data?.length;

                          if(_bikeProvider.threatFilterArray.contains(data!['type'])){
                            switch(_bikeProvider.threatFilterDate){
                              case ThreatFilterDate.all:
                                //_proceed(context, index, data, documentSnapshots);
                                return Column(
                                  children: [
                                    ListTile(
                                        leading: data == null ? const Text('Error')
                                            : SvgPicture.asset(
                                          getSecurityIconWidget(data['type']),
                                          height: 36.h,
                                          width: 36.w,
                                        ),
                                        title: data == null ? const Text('Error')
                                            : data["address"] != null
                                            ? Text(data["address"], style: EvieTextStyles.body18,)
                                            : FutureBuilder<dynamic>(
                                            future: _locationProvider.returnPlaceMarksString(data["geopoint"].latitude, data["geopoint"].longitude),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                _bikeProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, documentSnapshots[index].id,  snapshot.data.toString());
                                                return Text(
                                                  snapshot.data.toString(),
                                                  style:  EvieTextStyles.body18,
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
                                            : Text("${getSecurityTextWidget(data["type"])} • ${calculateTimeAgoWithTime(data["created"]!.toDate())}", style: EvieTextStyles.body12,)

                                    ),
                                    const Divider(height: 1),
                                  ],
                                );
                              case ThreatFilterDate.today:
                                if(calculateDateDifferenceFromNow(data['created'].toDate()) == 0){
                                  return Column(
                                    children: [
                                      ListTile(
                                          leading: data == null ? const Text('Error')
                                              : SvgPicture.asset(
                                            getSecurityIconWidget(data['type']),
                                            height: 36.h,
                                            width: 36.w,
                                          ),
                                          title: data == null ? const Text('Error')
                                              : data["address"] != null
                                              ? Text(data["address"], style: EvieTextStyles.body18,)
                                              : FutureBuilder<dynamic>(
                                              future: _locationProvider.returnPlaceMarksString(data["geopoint"].latitude, data["geopoint"].longitude),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  _bikeProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, documentSnapshots[index].id,  snapshot.data.toString());
                                                  return Text(
                                                    snapshot.data.toString(),
                                                    style:  EvieTextStyles.body18,
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
                                              : Text("${getSecurityTextWidget(data["type"])} • ${data["created"]!.toDate().toString()}", style:  EvieTextStyles.body14,)

                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }
                                break;
                              case ThreatFilterDate.yesterday:
                                if(calculateDateDifferenceFromNow(data['created'].toDate()) == -1){
                                  return Column(
                                    children: [
                                      ListTile(
                                          leading: data == null ? const Text('Error')
                                              : SvgPicture.asset(
                                            getSecurityIconWidget(data['type']),
                                            height: 36.h,
                                            width: 36.w,
                                          ),
                                          title: data == null ? const Text('Error')
                                              : data["address"] != null
                                              ? Text(data["address"], style:  EvieTextStyles.body18,)
                                              : FutureBuilder<dynamic>(
                                              future: _locationProvider.returnPlaceMarksString(data["geopoint"].latitude, data["geopoint"].longitude),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  _bikeProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, documentSnapshots[index].id,  snapshot.data.toString());
                                                  return Text(
                                                    snapshot.data.toString(),
                                                    style:  EvieTextStyles.body18,
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
                                              : Text("${getSecurityTextWidget(data["type"])} • ${data["created"]!.toDate().toString()}", style:  EvieTextStyles.body14,)

                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }
                                break;
                              case ThreatFilterDate.last7days:
                                if([-1,-2,-3,-4,-5,-6,-7].contains(calculateDateDifferenceFromNow(data['created'].toDate()))){
                                  return Column(
                                    children: [
                                      ListTile(
                                          leading: data == null ? const Text('Error')
                                              : SvgPicture.asset(
                                            getSecurityIconWidget(data['type']),
                                            height: 36.h,
                                            width: 36.w,
                                          ),
                                          title: data == null ? const Text('Error')
                                              : data["address"] != null
                                              ? Text(data["address"], style:  EvieTextStyles.body18,)
                                              : FutureBuilder<dynamic>(
                                              future: _locationProvider.returnPlaceMarksString(data["geopoint"].latitude, data["geopoint"].longitude),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  _bikeProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, documentSnapshots[index].id,  snapshot.data.toString());
                                                  return Text(
                                                    snapshot.data.toString(),
                                                    style:  EvieTextStyles.body18,
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
                                              : Text("${getSecurityTextWidget(data["type"])} • ${data["created"]!.toDate().toString()}", style:  EvieTextStyles.body14,)

                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }
                                break;
                              case ThreatFilterDate.custom:
                                if(data['created'].toDate().isAfter(_bikeProvider.threatFilterDate1)
                                    && data['created'].toDate().isBefore(_bikeProvider.threatFilterDate2)){
                                  return Column(
                                    children: [
                                      ListTile(
                                          leading: data == null ? const Text('Error')
                                              : SvgPicture.asset(
                                            getSecurityIconWidget(data['type']),
                                            height: 36.h,
                                            width: 36.w,
                                          ),
                                          title: data == null ? const Text('Error')
                                              : data["address"] != null
                                              ? Text(data["address"], style:  EvieTextStyles.body18,)
                                              : FutureBuilder<dynamic>(
                                              future: _locationProvider.returnPlaceMarksString(data["geopoint"].latitude, data["geopoint"].longitude),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  _bikeProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, documentSnapshots[index].id,  snapshot.data.toString());
                                                  return Text(
                                                    snapshot.data.toString(),
                                                    style:  EvieTextStyles.body18,
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
                                              : Text("${getSecurityTextWidget(data["type"])} • ${data["created"]!.toDate().toString()}", style: EvieTextStyles.body14,)

                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }
                                break;
                              default:
                                return Column(
                                  children: [
                                    ListTile(
                                        leading: data == null ? const Text('Error')
                                            : SvgPicture.asset(
                                          getSecurityIconWidget(data['type']),
                                          height: 36.h,
                                          width: 36.w,
                                        ),
                                        title: data == null ? const Text('Error') :
                                               data["address"] != null ?
                                               Text(data["address"], style:  EvieTextStyles.body18,) :
                                               FutureBuilder<dynamic>(
                                                 future: _locationProvider.returnPlaceMarksString(data["geopoint"].latitude, data["geopoint"].longitude),
                                                 builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      _bikeProvider.uploadPlaceMarkAddressToFirestore(_bikeProvider.currentBikeModel!.deviceIMEI!, documentSnapshots[index].id,  snapshot.data.toString());
                                                      return Text(
                                                       snapshot.data.toString(),
                                                       style: EvieTextStyles.body18,
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
                                            : Text("${getSecurityTextWidget(data["type"])} • ${data["created"]!.toDate().toString()}", style:  EvieTextStyles.body14,)

                                    ),
                                    const Divider(height: 1),
                                  ],
                                );
                            }
                            return Container();
                          }else {
                            return Container();
                          }
                        },
                        // orderBy is compulsory to enable pagination
                        query: FirebaseFirestore.instance.collection("bikes")
                              .doc(_bikeProvider.currentBikeModel!.deviceIMEI!)
                              .collection("events")
                              //.where('type', whereIn: ['lock'])
                              //.where('type', whereIn: _bikeProvider.threatFilterArray)
                              .orderBy("created", descending: true),

                        itemsPerPage:  10,
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
                // Padding(
                //   padding:
                //   const EdgeInsets.all(6),
                //   child:  Padding(
                //     padding: EdgeInsets.only(
                //         left: 16.w, right: 16.w, top: 0.h, bottom: 6.h),
                //     child: Container(
                //       height: 45.h,
                //       width: double.infinity,
                //       child: ElevatedButton(
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text(
                //               "Show All Data",
                //               style:  EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                //             ),
                //             SvgPicture.asset(
                //               "assets/buttons/external_link.svg",
                //             ),
                //           ],
                //         ),
                //         onPressed: () {},
                //         style: ElevatedButton.styleFrom(
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10.0),
                //               side:  BorderSide(color: Color(0xff7A7A79), width: 1.5.w)),
                //           elevation: 0.0,
                //           backgroundColor: EvieColors.transparent,
                //
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
      height: 750.h,
    );
  }


}
