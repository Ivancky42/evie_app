import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/enumerate.dart';
import '../../../../api/fonts.dart';
import '../../../../api/model/plan_model.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/setting_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../widgets/evie_appbar.dart';
import '../../../../widgets/evie_button.dart';
import '../../../../widgets/evie_container.dart';

class ProPlan extends StatefulWidget{
  const ProPlan({Key? key}) : super(key: key);

  @override
  State<ProPlan> createState() => _ProPlanState();
}

class _ProPlanState extends State<ProPlan> {

  late BikeProvider _bikeProvider;
  late PlanProvider _planProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _planProvider = Provider.of<PlanProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        _settingProvider.changeSheetElement(SheetList.currentPlan);
        return false;
      },

    child: Scaffold(
        backgroundColor: EvieColors.grayishWhite,
    appBar: PageAppbar(
    title: 'EV+ Subscription',
    onPressed: () {
      _settingProvider.changeSheetElement(SheetList.currentPlan);
    },
    ),
    body: Padding(
    padding: EdgeInsets.only(left: 16.w, right: 16.w, top:24.5.h),
    child: ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Container(
          height: 664.h,
          width: 326.w,
          decoration: BoxDecoration(
              color: EvieColors.dividerWhite,
              border: Border.all(
                color: EvieColors.dividerWhite,
              ),
              boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 10.0.w,
              blurRadius: 10.0.w,
            ),
          ],
              // boxShadow:[
              //   BoxShadow(
              //     color: EvieColors.dividerWhite,
              //     //spreadRadius: 2,
              //     blurRadius: 24,
              //     offset: Offset(0, 12),
              //   ),
              // ],
              borderRadius:
              BorderRadius.all(Radius.circular(10))),

          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 16.w, left: 16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 24.h, bottom: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "EV-Secure",
                              style: EvieTextStyles.body20.copyWith(color: EvieColors.darkGrayish),
                            ),

                          SizedBox(width: 9),
                          SvgPicture.asset(
                            "assets/icons/batch_tick.svg",
                          ),
                        ],
                      ),
                    ),


                    Text("\$29.90",style: EvieTextStyles.display),

                    Align(
                        alignment: Alignment(0.4, -12),
                        child: Text("/per month",style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayish),)),

                    Padding(
                      padding: EdgeInsets.only(top: 17.h, bottom: 16.h),
                      child: Text("You are currently on this plan.", style: EvieTextStyles.body16.copyWith(color: EvieColors.primaryColor),),
                    ),

                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.only(left:16.w, right:16.w),
                      child: Text("Orbital Anti-theft: Remote monitor bike status and receive theft alert notification.",
                        style: EvieTextStyles.body18.copyWith(
                          color: EvieColors.lightBlack,
                          height: 1.2.h,
                        ),
                      ),
                    ),



                    Padding(
                      padding: EdgeInsets.only(top: 14.h, bottom: 16.h),
                      child: Divider(height: 1.h,color: EvieColors.darkWhite,),
                    ),

                    Row(children: [
                      Text("Includes",style: EvieTextStyles.body18.copyWith(color: EvieColors.mediumLightBlack, fontWeight: FontWeight.bold),),
                    ]),

                    const PlanPageElementRow(content: "GPS tracking"),
                    const PlanPageElementRow(content: "Alert notification"),
                    const PlanPageElementRow(content: "Theft Detection"),
                    const PlanPageElementRow(content: "Remote monitoring"),
                    const PlanPageElementRow(content: "Ride history"),
                    const PlanPageElementRow(content: "Bike Sharing"),

                  ],
                ),
              ),


            ],
          ),
        ),
      ],
    ),
    )));
  }
}
