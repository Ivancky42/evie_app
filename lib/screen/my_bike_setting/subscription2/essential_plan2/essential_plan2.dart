import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import '../../../../widgets/evie_container.dart';


class EssentialPlan2 extends StatelessWidget{

  const EssentialPlan2({Key? key,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return   Padding(
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
                const BorderRadius.all(Radius.circular(10))),

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
                      Text("29.90",style: EvieTextStyles.display),

                      Align(
                          alignment: Alignment(0.3, -12),
                          child: Text("/per month",style:  EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayish),)),

                      SizedBox(height: 40.h,),
                      Text("Orbital Anti-theft: Remote monitor bike status and receive theft alert notification. ",
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}