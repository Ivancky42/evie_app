import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import '../../widgets/evie_double_button_dialog.dart';
import '../../widgets/evie_single_button_dialog.dart';

class ShareBikeDelete extends StatelessWidget {

  final BikeProvider bikeProvider;
  final int index;

  const ShareBikeDelete({
    Key? key,
    required this.bikeProvider,
    required this.index,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/delete.svg",
            height: 20.h,
            width: 20.w,
          ),
          Text(
            "Delete",
            style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xffECEDEB)),
          ),
        ],
      ),
      onPressed: (){
        SmartDialog.show(
            widget: EvieDoubleButtonDialogCupertino(
              title: "Are you sure you want to delete this user",
              content: 'Are you sure you want to delete this user',
              leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
              rightContent: "Yes",

              onPressedRight: () async {
                await bikeProvider.cancelSharedBikeStatus(bikeProvider.bikeUserList.values.elementAt(index).uid, bikeProvider.bikeUserList.values.elementAt(index).notificationId!).then((result){
                  ///Update user notification id status == removed
                  if(result == true){
                    SmartDialog.dismiss();
                    SmartDialog.show(widget: EvieSingleButtonDialogCupertino(
                        title: "Success",
                        content: "You deleted the bike",
                        rightContent: "Close",
                        onPressedRight: ()=> SmartDialog.dismiss()
                    ));
                  }
                  else {
                    SmartDialog.show(
                        widget: EvieSingleButtonDialogCupertino(
                            title: "Not success",
                            content: "Try again",
                            rightContent: "Close",
                            onPressedRight: ()=>SmartDialog.dismiss()
                        ));
                  }
                });

              },
            ));
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.w)),
        elevation: 0.0,
        backgroundColor: EvieColors.PrimaryColor,
        padding: EdgeInsets.symmetric(
            horizontal: 14.h, vertical: 14.h),
      ),
    );
  }
}



class ShareBikeLeave extends StatelessWidget {

  final BikeProvider bikeProvider;
  final int index;

  const ShareBikeLeave({
    Key? key,
    required this.bikeProvider,
    required this.index,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82.w,
      height: 35.h,
      child: ElevatedButton(
        child:    Text(
          "Leave",
          style: TextStyle(
              fontSize: 12.sp,
              color: EvieColors.PrimaryColor),
        ),
        onPressed: (){
          SmartDialog.show(
              widget: EvieDoubleButtonDialogCupertino(
                title: "Are you sure you want to leave?",
                content: 'Are you sure you want to leave?',
                leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
                rightContent: "Yes",
                onPressedRight: () async {
                  SmartDialog.dismiss();
         //         SmartDialog.showLoading();
                  bikeProvider.cancelSharedBikeStatus(bikeProvider.bikeUserList.values.elementAt(index).uid, bikeProvider.bikeUserList.values.elementAt(index).notificationId!).then((result){
                    ///Update user notification id status == removed
                    if(result == true){
                     bikeProvider.deleteBike(bikeProvider.bikeUserList.values.elementAt(index).uid).then((deleteResult){
                       if(deleteResult == true){
                         changeToUserHomePageScreen(context);
                         SmartDialog.show(
                             widget: EvieSingleButtonDialogCupertino(
                                 title: "Success",
                                 content: "Leave",
                                 rightContent: "Close",
                                 onPressedRight: (){
                                   SmartDialog.dismiss();
                                 }
                             ));
                       }else{
                         SmartDialog.show(
                             widget: EvieSingleButtonDialogCupertino(
                                 title: "Not success",
                                 content: "Try again",
                                 rightContent: "Close",
                                 onPressedRight: ()=>SmartDialog.dismiss()
                             ));
                       }
                      });
                    }
                    else {
                      SmartDialog.show(
                          widget: EvieSingleButtonDialogCupertino(
                              title: "Not success",
                              content: "Try again",
                              rightContent: "Close",
                              onPressedRight: ()=>SmartDialog.dismiss()
                          ));
                    }
                  });
                },
              ));
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.w)),
          elevation: 0.0,
          backgroundColor: Color(0xffDFE0E0),
        ),
      ),
    );
  }
}