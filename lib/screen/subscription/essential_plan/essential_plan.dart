import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import '../plan_page_widget.dart';



class EssentialPlan extends StatelessWidget{

  const EssentialPlan({Key? key,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return   Padding(
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
                        child: Text("Essential Plan", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500,color: Color(0xff7A7A79)),),
                      ),
                      Text("FREE",style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w900,),),

                      Align(
                          alignment: Alignment(0.3, -12),
                          child: Text("for life",style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400,color: Color(0xff7A7A79)),)),

                      SizedBox(height: 40.h,),
                      Text("Best for essential: Bike setting, lock and unlock bike",style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, height: 1.2.h),),

                      Padding(
                        padding: EdgeInsets.only(top: 14.h, bottom: 12.h),
                        child: Divider(height: 1.h,color: Color(0xff8E8E8E),),
                      ),

                      Row(children: [
                        Text("Includes",style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500,color: Color(0xff383838)),),
                      ]),

                      PlanPageElementRow(content: "Bike dashboard"),
                      PlanPageElementRow(content: "Bike setting"),
                      PlanPageElementRow(content: "Firmware updates"),
                      PlanPageElementRow(content: "Share bike???"),
                      PlanPageElementRow(content: "RFID unlocking"),
                      PlanPageElementRow(content: "App unlocking"),
                      PlanPageElementRow(content: "Integrated U-lock"),
                      PlanPageElementRow(content: "Theft Alarm"),
                      PlanPageElementRow(content: "Add multiple bike"),
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
