import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';


import '../api/colours.dart';
import '../api/fonts.dart';
import '../api/navigator.dart';
import '../api/provider/bike_provider.dart';
import '../api/provider/notification_provider.dart';

///Button Widget
class EvieActionableBar extends StatelessWidget {

  final String title;
  final String text;
  final Widget buttonLeft;
  final Widget buttonRight;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const EvieActionableBar({
    Key? key,
    required this.title,
    required this.text,
    required this.buttonLeft,
    required this.buttonRight,
    this.width,
    this.height,
    this.backgroundColor,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124.h,
            color: backgroundColor ?? EvieColors.grayishWhite,
            child: Padding(
              padding: EdgeInsets.only(left:16.w, right: 17.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.mediumLightBlack),),
                  Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400,color: EvieColors.darkGrayishCyan),),
                     Row(
                       children: [
                         Expanded(
                           child: Container(
                               height: 36.h,
                               child: buttonLeft),
                         ),

                         SizedBox(width: 8.w,),

                         Expanded(
                           child: Container(
                               height: 36.h,
                               child: buttonRight),
                         ),
                            ],
                          ),
          ],
        ),
      ),
    );
    // return Padding(
    //   padding: EdgeInsets.only(left:16.w, right: 17.w),
    //   child: Container(
    //       width: width,
    //       height: height,
    //       color: backgroundColor ?? EvieColors.grayishWhite,
    //       child: Column(
    //         children: [
    //           Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.mediumLightBlack),),
    //           Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400,color: EvieColors.darkGrayishCyan),),
    //           Expanded(
    //             child: Row(
    //               children: [
    //                 buttonLeft,
    //                 SizedBox(width: 19.5.w,),
    //                 buttonRight,
    //               ],
    //             ),
    //           ),
    //         ],
    //       )
    //   ),
    // );
  }
}


Widget stackActionableBar(context, BikeProvider bikeProvider, NotificationProvider notificationProvider){

  var items = [
    'Remind Me 3hr Later',
    'Remind Me Tomorrow',
    'Remind Me Next Week'
  ];
  ///Remind me 24 hours later, remind me tomorrow, remind me next week, etc

  return Visibility(
    visible: bikeProvider.rfidList.length == 0 && notificationProvider.isTimeArrive,
    child: EvieActionableBar(
        title: "Register EV-Key",
        text: "Add EV-Key to unlock your bike without app assistance.",
        buttonLeft: EvieButton_DropDown(
            onChanged: (value) async {
              if(value.toString() == items.elementAt(0)){
                await notificationProvider.setSharedPreferenceDate("targetDateTime", DateTime.now().add(const Duration(hours: 3)));
              }else if(value.toString() == items.elementAt(1)){
                await notificationProvider.setSharedPreferenceDate("targetDateTime", DateTime.now().add(const Duration(hours: 24)));
              }else if(value.toString() == items.elementAt(2)){
                await notificationProvider.setSharedPreferenceDate("targetDateTime", DateTime.now().add(const Duration(days: 7)));
              }
            },
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                    value,
                    style: EvieTextStyles.body16),

              );
            }).toList(),
            text: "Later"
        ),

        buttonRight: EvieButton(
          child: Text("Add Now",style: TextStyle(color: EvieColors.grayishWhite, fontSize: 17.sp, fontWeight: FontWeight.w900),),
          onPressed: (){
            changeToEVKey(context);
          },)),
  );
}
