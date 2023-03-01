import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import '../../../../widgets/evie_container.dart';


class EssentialPlan extends StatelessWidget{

  const EssentialPlan({Key? key,}) : super(key: key);


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
                        child: Text("Starter", style: EvieTextStyles.body20.copyWith(color: EvieColors.darkGrayish),),
                      ),
                      Text("FREE",style: EvieTextStyles.display),

                      Align(
                          alignment: Alignment(0.3, -12),
                          child: Text("for life",style:  EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayish),)),

                      SizedBox(height: 40.h,),
                      Text("Best for essential: Bike setting, lock and unlock bike.",
                          style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack,height: 1.2.h)),

                      Padding(
                        padding: EdgeInsets.only(top: 14.h, bottom: 12.h),
                        child: Divider(height: 1.h,color: EvieColors.darkWhite,),
                      ),

                      Row(children: [
                        Text("Includes",style: EvieTextStyles.body18.copyWith(color: EvieColors.mediumLightBlack, fontWeight: FontWeight.bold),),
                      ]),

                      const PlanPageElementRow(content: "Bike dashboard"),
                      const PlanPageElementRow(content: "Bike setting"),
                      const PlanPageElementRow(content: "Firmware updates"),
                      const PlanPageElementRow(content: "EV-Key unlocking"),
                      const PlanPageElementRow(content: "App unlocking"),
                      const PlanPageElementRow(content: "Integrated U-lock"),
                      const PlanPageElementRow(content: "Theft Alarm"),
                      const PlanPageElementRow(content: "Add multiple bike"),
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
