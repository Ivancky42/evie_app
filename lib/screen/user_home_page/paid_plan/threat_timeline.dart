
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_bike/api/dialog.dart';
import 'package:evie_bike/api/fonts.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:evie_bike/widgets/evie_divider.dart';
import 'package:evie_bike/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';


import '../../../api/colours.dart';
import '../../../api/function.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../widgets/evie_radio_button.dart';
import '../../../widgets/evie_switch.dart';

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

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        color: EvieColors.grayishWhite,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [

          Container(
            color: EvieColors.lightBlack,
            child: Padding(
              padding: EdgeInsets.only(left: 17.w, top: 45.h, bottom: 11.h, right:17.w),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  GestureDetector(
                      onTap: (){
                        showExitOrbitalAntiTheft(context);
                      },
                      child: SvgPicture.asset(
                        "assets/buttons/close.svg",
                      )),
                  Text(
                    "Orbital Anti-theft",
                    style: EvieTextStyles.h2.copyWith(color: EvieColors.grayishWhite),
                  ),

                  GestureDetector(
                      onTap: (){
                        changeToThreatMap(context);
                      },
                      child: SvgPicture.asset(
                        "assets/buttons/list_selected.svg",
                      )),
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
                        //contentsAlign: ContentsAlign.alternating, ///Right left
                        contentsAlign: ContentsAlign.basic,
                        startConnectorBuilder: (context, index) {
                          if(index == 0){
                            return const TransparentConnector();
                          }else{
                            return   const DashedLineConnector();
                          }
                        },
                        endConnectorBuilder: (context, index) {
                          if(index == _bikeProvider.threatRoutesLists.length - 1){
                            return const TransparentConnector();
                          }else {
                            return const DashedLineConnector();
                          }
                        },
                        indicatorBuilder: (context, index) {
                          if(index == 0){
                            return SvgPicture.asset(
                              "assets/icons/vector.svg",
                              height: 20,
                            );
                          }else{
                            return DotIndicator();
                          }
                        },
                          oppositeContentsBuilder: (context, index){
                          return Container();
                          },
                        contentsBuilder: (context, index) {
                           return Padding(
                            padding:  EdgeInsets.fromLTRB(18.h,18.h,18.h,0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _bikeProvider.threatRoutesLists.values.elementAt(index) == null ? const Text('Error')
                                    : _bikeProvider.threatRoutesLists.values.elementAt(index).address != null
                                    ? Text(_bikeProvider.threatRoutesLists.values.elementAt(index).address, style: EvieTextStyles.body18,)
                                    :  FutureBuilder<dynamic>(
                                    future: _locationProvider.returnPlaceMarks(
                                        _bikeProvider.threatRoutesLists.values.elementAt(index).geopoint.latitude,
                                        _bikeProvider.threatRoutesLists.values.elementAt(index).geopoint.longitude
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                            _bikeProvider.uploadThreatRoutesAddressToFirestore(
                                            _bikeProvider.currentBikeModel!.location!.eventId!,
                                            _bikeProvider.threatRoutesLists.keys.elementAt(index),
                                            snapshot.data.name.toString());
                                        return Text(
                                          snapshot.data.name.toString(),
                                          style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                                        );
                                      }else{
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

                               SizedBox(height: 12.h,),
                               EvieDivider(),
                              ],
                            ),
                            );
                        },
                      ),
                    ),
                ],),
              ),
            ),
          )
        ],
      ),
      height: 750.h,
    );
  }
}
