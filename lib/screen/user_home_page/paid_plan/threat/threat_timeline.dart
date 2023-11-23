
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:timelines/timelines.dart';


import '../../../../api/colours.dart';
import '../../../../api/function.dart';
import '../../../../api/model/threat_routes_model.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../../../widgets/evie_radio_button.dart';
import '../../../../widgets/evie_single_button_dialog.dart';
import '../../../../widgets/evie_switch.dart';
import '../home_element/location.dart';
import '../home_element/threat_unlocking_system.dart';

class ThreatTimeLine extends StatefulWidget {

  const ThreatTimeLine({Key? key,}) : super(key: key);

  @override
  State<ThreatTimeLine> createState() => _ThreatTimeLineState();
}

class _ThreatTimeLineState extends State<ThreatTimeLine> {

  late BikeProvider _bikeProvider;
  late LocationProvider _locationProvider;

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 244.h;
  double _panelHeightClosed = 95.h;
  late final ScrollController scrollController;
  late final PanelController panelController;

  @override
  void initState() {
    // TODO: implement initState
    scrollController = ScrollController();
    panelController = PanelController();
    super.initState();
    _fabHeight = _initFabHeight;
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .30;
    _bikeProvider = Provider.of<BikeProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        color: EvieColors.grayishWhite,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: Platform.isIOS ? 120.h : 90.h,
                color: EvieColors.lightBlack,
                child: Padding(
                  padding: EdgeInsets.only(left: 17.w, top: Platform.isIOS ? 50.h : 30.h, bottom: 0, right:17.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: (){
                            showEvieExitOrbitalDialog(context);
                          },
                          child: SvgPicture.asset(
                            "assets/buttons/close.svg",
                          )),
                      Text(
                        "Orbital Anti-theft",
                        style: EvieTextStyles.h2.copyWith(color: EvieColors.grayishWhite),
                      ),

                      // GestureDetector(
                      //     onTap: (){
                      //       changeToThreatMap(context, false, PageTransitionType.fade);
                      //     },
                      //     child: SvgPicture.asset(
                      //       "assets/buttons/list_selected.svg",
                      //     )),

                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          changeToThreatMap(context, false, PageTransitionType.fade);
                        },
                        icon: SvgPicture.asset(
                          "assets/buttons/list_selected.svg",
                          width: 40.w,
                          height: 40.w,
                        )
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Timeline.tileBuilder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          theme: TimelineThemeData(
                            color: EvieColors.mediumLightBlack,
                            nodePosition: 0.08,
                            indicatorPosition: 0.5,
                          ),
                          shrinkWrap: true,
                          builder: TimelineTileBuilder(
                            itemCount: _bikeProvider.threatRoutesLists.length,
                            contentsAlign: ContentsAlign.basic,
                            startConnectorBuilder: (context, index) {
                              if(index == 0){
                                return const TransparentConnector();
                              }
                              else{
                                return const DashedLineConnector(thickness: 1.2, color: EvieColors.lightGrayish);
                              }
                            },
                            endConnectorBuilder: (context, index) {
                              if(index == _bikeProvider.threatRoutesLists.length - 1){
                                return const TransparentConnector();
                              }else {
                                return const DashedLineConnector(thickness: 1.2, color: EvieColors.lightGrayish);
                              }
                            },
                            indicatorBuilder: (context, index) {
                              ThreatRoutesModel threatRoutesModel =_bikeProvider.threatRoutesLists.values.elementAt(index);
                              if (index == 0) {
                                if (threatRoutesModel.geopoint?.latitude != 0 &&
                                    threatRoutesModel.geopoint?.longitude !=
                                        0) {
                                  return SvgPicture.asset(
                                    "assets/icons/vector.svg",
                                    width: 21.74.w,
                                    height: 29.h,
                                  );
                                }
                                else {
                                  return SvgPicture.asset(
                                    "assets/icons/notification_alert.svg",
                                  );
                                }
                              }
                              else {
                                if (threatRoutesModel.geopoint?.latitude != 0 &&
                                    threatRoutesModel.geopoint?.longitude !=
                                        0) {
                                  return Container(
                                    width: 22.5.w,
                                    height: 20.h,
                                    //color: Colors.green,
                                    child: DotIndicator(
                                      color: EvieColors.veryLightRed,),
                                  );
                                }
                                else {
                                  return SvgPicture.asset(
                                    "assets/icons/notification_alert.svg",
                                  );
                                }
                              }
                            },
                            oppositeContentsBuilder: (context, index){
                              return Container();
                            },
                            contentsBuilder: (context, index) {
                              ThreatRoutesModel threatRoutesModel =_bikeProvider.threatRoutesLists.values.elementAt(index);
                              if (threatRoutesModel.geopoint?.latitude != 0 && threatRoutesModel.geopoint?.longitude != 0) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:  EdgeInsets.fromLTRB(18.h, 12.h, 18.h, 12.h),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _bikeProvider.threatRoutesLists.values.elementAt(index) == null ? const Text('Error')
                                              : _bikeProvider.threatRoutesLists.values.elementAt(index).address != null && _bikeProvider.threatRoutesLists.values.elementAt(index).address != 'null'
                                              ? Text(_bikeProvider.threatRoutesLists.values.elementAt(index).address, style: EvieTextStyles.body18,)
                                              :  FutureBuilder<dynamic>(
                                              future: _locationProvider.returnPlaceMarksString(
                                                  _bikeProvider.threatRoutesLists.values.elementAt(index).geopoint.latitude,
                                                  _bikeProvider.threatRoutesLists.values.elementAt(index).geopoint.longitude
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  _bikeProvider.uploadThreatRoutesAddressToFirestore(
                                                      _bikeProvider.currentBikeModel!.location!.eventId!,
                                                      _bikeProvider.threatRoutesLists.keys.elementAt(index),
                                                      snapshot.data.toString());
                                                  return Text(
                                                    snapshot.data.toString(),
                                                    style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                                                  );
                                                }
                                                else{
                                                  return Text(
                                                    "loading",
                                                    style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                                                  );
                                                }
                                              }
                                          ),

                                          Text("${"Theft Attempt"} • ${calculateTimeAgoWithTime(
                                              _bikeProvider.threatRoutesLists.values.elementAt(index).created.toDate())}",
                                            style: EvieTextStyles.body12,),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 18.h),
                                      child: EvieDivider(thickness: 0.15.h,),
                                    )
                                  ],
                                );
                              }
                              else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:  EdgeInsets.fromLTRB(18.h, 12.h, 18.h, 12.h),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Location not found',
                                            style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                                          ),

                                          RichText(
                                            text: TextSpan(
                                              text: "Why did this happen?",
                                              style: EvieTextStyles.body14.copyWith(color: Colors.black, fontFamily: 'Avenir', decoration: TextDecoration.underline),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  showGPSNotFound();
                                                  },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 18.h),
                                      child: EvieDivider(thickness: 0.15.h,),
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ],),
                  ),
                ),
              ),

              SlidingUpPanel(
                panelSnapping: false,
                disableDraggableOnScrolling: false,
                color: EvieColors.grayishWhite2,
                header: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ForceDraggableWidget(
                        child: Container(
                          width: 100,
                          height: 40,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 12.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 40.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                        color: EvieColors.lightGrayishCyan,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                maxHeight: _panelHeightOpen,
                minHeight: _panelHeightClosed,
                parallaxEnabled: true,
                parallaxOffset: .5,
                body: Container(),
                controller: panelController,
                scrollController: scrollController,
                panelBuilder: () => Padding(
                  padding:  EdgeInsets.only(bottom:23.h),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 2, 6, 8),
                              child: Location(),
                            ),
                          ),
                        ),

                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(6, 2, 16, 8),
                              child: ThreatUnlockingSystem(page: 'map'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                boxShadow: [],
                border: Border.all(color: EvieColors.lightGrayishCyan, width: 1.5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0)),
                onPanelSlide: (double pos) => setState(() {
                  _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                      _initFabHeight;
                }),
              ),
            ],
          ),
        ],
      ),
      height: 750.h,
    );
  }
}
