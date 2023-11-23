import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/ride_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../api/enumerate.dart';
import '../../api/fonts.dart';
import '../../api/function.dart';
import '../../api/model/trip_history_model.dart';
import '../../api/sheet.dart';


class RecentActivity extends StatefulWidget{
  final RideFormat format;
  final bool isDataEmpty;
  const RecentActivity(this.format, this.isDataEmpty, { Key? key }) : super(key: key);
  @override
  _RecentActivityState createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {

  List<String> totalData = ["Mileage", "No of Ride", "Carbon Footprint"];
  late String currentData;

  late List<ChartData> chartData = [];
  late TooltipBehavior _tooltip;
  late NumericAxis xNumericAxis;

  DateTime? pickedDate = DateTime.now();

  late BikeProvider _bikeProvider;
  late RideProvider _rideProvider;
  late SettingProvider _settingProvider;

  List<TripHistoryModel> tripList = [];


  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _rideProvider = Provider.of<RideProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    if (widget.format == RideFormat.day) {
      tripList = _rideProvider.dayRideHistoryList;
    }
    else if (widget.format == RideFormat.week) {
      tripList = _rideProvider.weekRideHistoryList;
    }
    else if (widget.format == RideFormat.month) {
      tripList = _rideProvider.monthRideHistoryList;
    }

    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Container(
          color: EvieColors.dividerWhite,
          width: double.infinity,
          child: Padding(
            padding:  EdgeInsets.only(top: 10.h, left: 16.w, right: 16.w, bottom: 10.h),
            child: Text("Trips", style: EvieTextStyles.h4),
          ),
        ),

        Visibility(
            visible: widget.isDataEmpty,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, top: 10.h),
              child: Text("No records",style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan),),
            )
        ),

        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) {
            //return Divider(height: 1.h);
            return const SizedBox.shrink();
          },
          itemCount: tripList.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    //Navigator.pop(context);
                    showRideHistorySheet(context, _rideProvider.currentTripHistoryLists.keys.elementAt(index), tripList[index]);
                  },
                  child: Container(
                    height: 77.h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text(
                                calculateDateAgo(tripList[index].startTime!.toDate(), tripList[index].endTime!.toDate()),

                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                              SvgPicture.asset(
                                "assets/buttons/next.svg",
                                height: 24.h,
                                width: 24.w,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _settingProvider.currentMeasurementSetting == MeasurementSetting.metricSystem ?
                              Text(
                                "${(tripList[index].distance!.toDouble()/1000).toStringAsFixed(2)} km",
                                style: EvieTextStyles.h4.copyWith(color: EvieColors.lightBlack),
                              ):
                              Text(
                                "${_settingProvider.convertMeterToMilesInString((tripList[index].distance!.toDouble()))}miles",
                                style: EvieTextStyles.h4.copyWith(color: EvieColors.lightBlack),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${thousandFormatting(tripList[index].carbonPrint!)}",
                                      style: EvieTextStyles.body14.copyWith(color: EvieColors.lightBlack, fontFamily: 'Avenir', fontWeight: FontWeight.w400, height: EvieTextStyles.lineHeight)
                                    ),
                                    TextSpan(
                                      text: " g CO2 Saved",
                                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan, fontFamily: 'Avenir', fontWeight: FontWeight.w400, height: EvieTextStyles.lineHeight)
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const EvieDivider(),
              ],
            );
          },
        ),
      ],);
  }

}

