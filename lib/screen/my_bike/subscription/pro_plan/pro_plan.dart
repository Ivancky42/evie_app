import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';


import '../../../../api/model/plan_model.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../widgets/evie_button.dart';
import '../plan_page_widget.dart';

class ProPlan extends StatefulWidget{
  const ProPlan({Key? key,}) : super(key: key);

  @override
  State<ProPlan> createState() => _ProPlanState();
}

class _ProPlanState extends State<ProPlan> {

  late BikeProvider _bikeProvider;
  late PlanProvider _planProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _planProvider = Provider.of<PlanProvider>(context);

    return Padding(
      padding: EdgeInsets.only(left: 32.w, right: 32.w),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 664.h,
            width: 326.w,
            decoration: BoxDecoration(
                color: Color(0xffDFE0E0),
                border: Border.all(
                  color: Color(0xffDFE0E0),
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
                        child: Text("Pro Plan", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500,color: Color(0xff7A7A79)),),
                      ),
                      Text("USD29.90",style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w900,),),

                      Align(
                          alignment: Alignment(0.3, -12),
                          child: Text("/per month",style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400,color: Color(0xff7A7A79)),)),

                      SizedBox(height: 40.h,),
                      Text("Best for peace of mind: Remote monitor bike status and receive theft detection alert notification",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400,  height: 1.2.h),),

                      Padding(
                        padding: EdgeInsets.only(top: 14.h, bottom: 12.h),
                        child: Divider(height: 1.h,color: Color(0xff8E8E8E),),
                      ),

                      Row(children: [
                        Text("Includes",style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500,color: Color(0xff383838)),),
                      ]),

                      PlanPageElementRow(content: "All Essential includes"),
                      PlanPageElementRow(content: "GPS tracking"),
                      PlanPageElementRow(content: "Alert notification"),
                      PlanPageElementRow(content: "Theft detection"),
                      PlanPageElementRow(content: "Remote monitoring"),
                      PlanPageElementRow(content: "Fall detection with alerts"),
                      PlanPageElementRow(content: "Ride history"),
                      PlanPageElementRow(content: "Exclusive promotions"),
                      PlanPageElementRow(content: "Unlimited data package"),

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
                          color: EvieColors.PrimaryColor,
                          border: Border.all(
                            color: EvieColors.PrimaryColor,
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
                  visible: !_bikeProvider.isPlanSubscript!,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, 16.h),
                      child:   EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                          "Unlock Plan",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700
                          ),
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
