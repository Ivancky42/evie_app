import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

showConnectedToast() {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 358.w,
            alignment: Alignment.centerLeft,
            height: 44.h,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  SvgPicture.asset("assets/icons/check.svg"),
                  SizedBox(width: 4.w,),
                  Text(
                    "Bike Connected.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: Colors.black,
            ),
          )
      ));
}

showConnectingToast() {
  SmartDialog.showToast("",
      isLoadingTemp: true,
      time: Duration(seconds: 30),
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 358.w,
            alignment: Alignment.centerLeft,
            height: 44.h,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  SvgPicture.asset("assets/icons/loading.svg"),
                  SizedBox(width: 4.w,),
                  Text(
                    "Connecting bike.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: Colors.black,
            ),
          )
      ));
}

showScanTimeoutToast() {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 358.w,
            height: 44.h,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                  SizedBox(width: 4.w,),
                  Text(
                    "Scan timeout. Please try again.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: Colors.black,
            ),
          ),
      ));
}

showScanErrorToast() {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 358.w,
            alignment: Alignment.centerLeft,
            height: 44.h,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                  SizedBox(width: 4.w,),
                  Text(
                    "Scan Error. Please re-enabled your bluetooth.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: Colors.black,
            ),
          )
      ));
}

showConnectErrorToast() {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 358.w,
            alignment: Alignment.centerLeft,
            height: 44.h,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                  SizedBox(width: 4.w,),
                  Text(
                    "Connect Error. Please try again.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: Colors.black,
            ),
          )
      ));
}

showDisconnectedToast() {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 358.w,
            alignment: Alignment.centerLeft,
            height: 44.h,
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                  SizedBox(width: 4.w,),
                  Text(
                    "Bike disconnected.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: Colors.black,
            ),
          )
      ));
}

showControlAdmissionToast() {
  SmartDialog.showToast("",
      alignment: Alignment.bottomLeft,
      widget: Container(
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        height: double.infinity,
        child: Wrap(
          children: [
            Container(
              width: 358.w,
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 0.w, 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 320.w,
                      height: 44.h,
                      child: Text(
                        "Your account doesn't have control admission for this setting.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ));
}

showUpgradePlanToast() {
  SmartDialog.showToast("",
      alignment: Alignment.bottomLeft,
      widget: Container(
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        height: double.infinity,
        child: Wrap(
          children: [
            Container(
              width: 358.w,
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 0.w, 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 320.w,
                      height: 60.h,
                      child: Text(
                        "This feature only available for pro plan user. You can upgrade your plan in setting page. ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ));
}


