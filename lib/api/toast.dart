import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import '../bluetooth/modelResult.dart';
import 'fonts.dart';
import 'model/bike_model.dart';

showTextToast(String msg) {
  SmartDialog.showToast("",
      clickBgDismissTemp: true,
      widget: GestureDetector(
        onTap: () {
          SmartDialog.dismiss(status: SmartStatus.toast);
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
                        color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
                        offset: Offset(0, 8), // X and Y offset
                        blurRadius: 16, // Blur radius
                        spreadRadius: 0, // Spread radius
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
      )
  );
}
