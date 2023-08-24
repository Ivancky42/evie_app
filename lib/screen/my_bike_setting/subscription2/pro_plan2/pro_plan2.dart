import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';


import '../../../../api/fonts.dart';
import '../../../../api/model/plan_model.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../widgets/evie_button.dart';
import '../../../../widgets/evie_container.dart';


class ProPlan2 extends StatefulWidget{
  const ProPlan2({Key? key,}) : super(key: key);

  @override
  State<ProPlan2> createState() => _ProPlan2State();
}

class _ProPlan2State extends State<ProPlan2> {

  late BikeProvider _bikeProvider;
  late PlanProvider _planProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _planProvider = Provider.of<PlanProvider>(context);

    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 664.h,
            width: 326.w,
            decoration: BoxDecoration(
                color: EvieColors.lightGrayishCyan,
                border: Border.all(
                  color: EvieColors.lightGrayishCyan,
                ),
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
                        padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
                        child: Text("EV-Secure", style: EvieTextStyles.body20.copyWith(color: EvieColors.darkGrayish),),
                      ),
                      Text("USD29.90",style: EvieTextStyles.display),

                      Align(
                          alignment: Alignment(0.3, -12),
                          child: Text("/per month",style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayish),)),

                      Padding(
                        padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                        child: Text("You are currently on this plan.", style: EvieTextStyles.body16.copyWith(color: EvieColors.primaryColor),),
                      ),

                      SizedBox(height: 40.h,),
                      Text("Orbital Anti-theft: Remote monitor bike status and receive theft alert notification.",
                          style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack,height: 1.2.h)),

                      Padding(
                        padding: EdgeInsets.only(top: 14.h, bottom: 12.h),
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

                Align(
                  alignment: Alignment(-1.9.h,-0.94.h),
                  child:RotationTransition(
                    turns: new AlwaysStoppedAnimation(-45 / 360),
                    child: Container(
                      height: 28.h,
                      width: 200.w,
                      decoration: BoxDecoration(
                          color: EvieColors.primaryColor,
                          border: Border.all(
                            color: EvieColors.primaryColor,
                          ),
                          borderRadius:
                          BorderRadius.all(Radius.circular(5))),
                      child: Center(
                        child: Text(
                          "Best Value",
                          style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w900,
                              color: Color(0xffECEDEB)),
                        ),
                      ),
                    ),
                  ),
                ),

                Visibility(
                  visible: !_bikeProvider.isPlanSubscript! && _bikeProvider.isOwner == true,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, 16.h),
                      child:   EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                            "Upgrade Now",
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                        ),
                        onPressed: () {
                          String key = _planProvider.availablePlanList.keys.elementAt(0);
                          PlanModel planModel = _planProvider.availablePlanList[key];

                          _planProvider.getPrice(planModel).then((priceModel) {
                            _planProvider.purchasePlan(_bikeProvider.currentBikeModel!.deviceIMEI!, planModel.id!, priceModel.id).then((value) {
                              changeToStripeCheckoutScreen(context, value, _bikeProvider.currentBikeModel!, planModel, priceModel);
                            });
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
