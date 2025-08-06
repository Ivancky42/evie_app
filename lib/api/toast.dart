import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'fonts.dart';

showTextToast(String msg) {
  SmartDialog.show(
    builder: (_) => GestureDetector(
      onTap: () {
        SmartDialog.dismiss();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                decoration:BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7A7A79).withOpacity(0.15),
                      offset: Offset(0, 8),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                height: 84.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/icons/check.svg"),
                      SizedBox(width: 4.w,),
                      Flexible(child: Text(
                        msg,
                        style: EvieTextStyles.toast,
                      ),)
                    ],
                  ),
                )
            )
        ),
      ),
    ),
    backDismiss: true,
  );
}

showEVSecureActivatedInToast(String msg) {
  SmartDialog.show(
    builder: (_) => GestureDetector(
      onTap: () {
        SmartDialog.dismiss();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                decoration:BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7A7A79).withOpacity(0.15),
                      offset: Offset(0, 8),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                height: 56.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/icons/check.svg"),
                      SizedBox(width: 4.w,),
                      Flexible(child: Text(
                        msg,
                        style: EvieTextStyles.toast,
                      ),)
                    ],
                  ),
                )
            )
        ),
      ),
    ),
    backDismiss: true,
  );
}
