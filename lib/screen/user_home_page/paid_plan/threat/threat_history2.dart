import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../api/attach.dart';
import '../../../../api/colours.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/function.dart';
import '../../../../api/model/event_model.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../../../api/provider/setting_provider.dart';
import '../home_element/orbital_list_container.dart';


class ThreatHistory2 extends StatefulWidget {


  const ThreatHistory2({super.key});

  @override
  State<ThreatHistory2> createState() => _ThreatHistory2State();
}

class _ThreatHistory2State extends State<ThreatHistory2> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late SettingProvider _settingProvider;

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  bool isPickedStatusExpand = false;
  bool isPickedDateExpand = false;

  static const _pageSize = 10;

  List<EventModel> eventList = [];
  final ScrollController _scrollController = ScrollController();
  bool isScrolling = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.isScrollingNotifier.value) {
        // The scrollbar is in a scrolling state.
        if (!isScrolling) {
          setState(() {
            isScrolling = true;
          });
        }
      } else {
        // The scrollbar is not in a scrolling state (original state).
        setState(() {
          isScrolling = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  
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
        mainAxisSize: MainAxisSize.min,
        children: [
          isScrolling ?
          SizedBox(
          height: 48.h,
            child: Row(
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
                  padding: EdgeInsets.only(right:10.w),
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
          ) :
          SizedBox(
            height: 48.h,
            child: Row(
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
                  padding: EdgeInsets.only(right:10.w),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _locationProvider.locations();
                      _settingProvider.changeSheetElement(SheetList.mapDetails);
                    },
                    icon: SvgPicture.asset(
                      "assets/buttons/list_selected.svg",
                      width: 40.w,
                      height: 40.w,
                    ),
                  ),
                ),
              ],
            ),
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
                  visible: _bikeProvider.threatFilterDate != ThreatFilterDate.all || _bikeProvider.threatFilterArray.length != 5,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: GestureDetector(
                      child: SvgPicture.asset('assets/icons/x.svg', height: 33.h,),
                      onTap: () async {
                        _bikeProvider.applyThreatFilterDate(ThreatFilterDate.all, DateTime.now(), DateTime.now());
                        List<String> filter = ["warning","fall","danger","lock", "unlock"];
                        await _bikeProvider.applyThreatFilterStatus(filter);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: SizedBox(
                    height: 33.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isPickedStatusExpand = true;
                        });
                        showFilterTreatStatus(context, _bikeProvider, isPickedStatusExpand ,setState);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side:  _bikeProvider.threatFilterArray.isNotEmpty ? BorderSide(color: EvieColors.darkGray, width: 1.0.w) : BorderSide(color: EvieColors.transparent,width: 0)),
                        elevation: 0.0,
                        backgroundColor: _bikeProvider.threatFilterArray.length == 5 ? EvieColors.transparent : EvieColors.progressBarGrey,
                        padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 0),
                      ),
                      child: _bikeProvider.threatFilterArray.length == 5 ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Status",
                            style: EvieTextStyles.ctaSmall.copyWith(color: EvieColors.darkGray),
                          ),
                          SizedBox(width: 4.w,),
                          SvgPicture.asset(
                            "assets/buttons/down_mini_bold.svg",
                          ),
                        ],
                      ) :
                      _bikeProvider.threatFilterArray.length == 1 ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getSecurityTextWidget(_bikeProvider.threatFilterArray[0]),
                            style: EvieTextStyles.ctaSmall.copyWith(color: EvieColors.darkGray),
                          ),
                          SizedBox(width: 4.w,),
                          SvgPicture.asset(
                            "assets/buttons/up-mini.svg",
                          ),
                        ],
                      ) :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_bikeProvider.threatFilterArray.length} Statuses",
                            style: EvieTextStyles.ctaSmall.copyWith(color: _bikeProvider.threatFilterArray.isNotEmpty ? EvieColors.darkGray : EvieColors.dividerWhite),
                          ),
                          SvgPicture.asset(
                            "assets/buttons/up-mini.svg",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0.w, right: 12.w),
                  child: Container(
                    height: 33.h,
                    padding: EdgeInsets.zero,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isPickedDateExpand = true;
                        });
                        showFilterTreatDate(context, _bikeProvider, isPickedDateExpand ,setState);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side:  _bikeProvider.threatFilterDate == ThreatFilterDate.all ? BorderSide(color: EvieColors.darkGray, width: 1.0.w) : BorderSide(color: EvieColors.darkGray,width: 1.0.w)),
                        elevation: 0.0,
                        backgroundColor: _bikeProvider.threatFilterDate == ThreatFilterDate.all ? EvieColors.transparent : EvieColors.progressBarGrey,
                        padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Date",
                            style: EvieTextStyles.ctaSmall.copyWith(color: _bikeProvider.threatFilterDate == ThreatFilterDate.all ? EvieColors.darkGray : EvieColors.darkGray),
                          ),
                          SizedBox(width: 4.w,),
                          SvgPicture.asset(
                            _bikeProvider.threatFilterDate == ThreatFilterDate.all ? "assets/buttons/down_mini_bold.svg" : "assets/buttons/up-mini.svg",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],),
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 9.h),
              child: NotificationListener<ScrollNotification> (
                onNotification: (scrollNotification) {
                  return true; // Continue to bubble the notification.
                },
                child: Scrollbar(
                  thumbVisibility: true,
                  child: RefreshIndicator(
                    color: EvieColors.primaryColor,
                    child: PaginateFirestore(
                      initialLoader: Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: EvieColors.primaryColor,),
                      ),
                      bottomLoader: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 24),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: EvieColors.primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      itemBuilderType: PaginateBuilderType.listView, //Change types accordingly
                      itemBuilder: (context, documentSnapshots, index) {
                        if (index < documentSnapshots.length) {
                          DocumentSnapshot snapshot = documentSnapshots[index];
                          Map<String, dynamic>? obj = snapshot.data() as Map<String, dynamic>?;
                          if (obj != null) {
                            EventModel eventModel = EventModel.fromJson(snapshot.id, obj);
                            if (eventModel.type != 'lost') {
                              if(_bikeProvider.threatFilterArray.contains(eventModel.type)){
                                switch(_bikeProvider.threatFilterDate) {
                                  case ThreatFilterDate.all:
                                    return Padding(
                                      padding: EdgeInsets.only(left: 16.w),
                                      child: OrbitalListContainer(eventModel: eventModel),
                                    );
                                  case ThreatFilterDate.today:
                                    if(calculateDateDifferenceFromNow(eventModel.created!) == 0){
                                      return Padding(
                                        padding: EdgeInsets.only(left: 16.w),
                                        child: OrbitalListContainer(eventModel: eventModel),
                                      );
                                    }
                                    break;
                                  case ThreatFilterDate.yesterday:
                                    if(calculateDateDifferenceFromNow(eventModel.created!) == -1){
                                      return Padding(
                                        padding: EdgeInsets.only(left: 16.w),
                                        child: OrbitalListContainer(eventModel: eventModel),
                                      );
                                    }
                                    break;
                                  case ThreatFilterDate.last7days:
                                    if([-1,-2,-3,-4,-5,-6,-7].contains(calculateDateDifferenceFromNow(eventModel.created!))){
                                      return Padding(
                                        padding: EdgeInsets.only(left: 16.w),
                                        child: OrbitalListContainer(eventModel: eventModel),
                                      );
                                    }
                                    break;
                                  case ThreatFilterDate.custom:
                                    if(eventModel.created!.isAfter(_bikeProvider.threatFilterDate1!) && eventModel.created!.isBefore(_bikeProvider.threatFilterDate2!)){
                                      return Padding(
                                        padding: EdgeInsets.only(left: 16.w),
                                        child: OrbitalListContainer(eventModel: eventModel),
                                      );
                                    }
                                    break;
                                  default:
                                    return Padding(
                                      padding: EdgeInsets.only(left: 16.w),
                                      child: OrbitalListContainer(eventModel: eventModel),
                                    );
                                }
                                return Container();
                              }
                            }
                            else {
                              return Container();
                            }
                          }
                        }
                        // Return a placeholder or an empty widget if there's no data to display
                        return Container();
                      },
                      // orderBy is compulsory to enable pagination
                      query: FirebaseFirestore.instance.collection("bikes")
                          .doc(_bikeProvider.currentBikeModel!.deviceIMEI!)
                          .collection("events")
                          .orderBy("created", descending: true).limit(_pageSize),
                      itemsPerPage:  _pageSize,
                      // to fetch real-time data
                      isLive: false,
                      listeners: [
                        refreshChangeListener,
                      ],
                      onEmpty: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 177.h,),
                            SizedBox(
                              width: 200.w,
                              height: 181.h,
                              child: SvgPicture.asset("assets/images/ev-secure.svg",),
                            ),
                            SizedBox(height: 18.h,),
                            Text(
                              'Start riding to fill this space with your adventures!',
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                            )
                          ],
                        ),
                      ),
                    ),
                    onRefresh: () async {
                      refreshChangeListener.refreshed = true;
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }


}
