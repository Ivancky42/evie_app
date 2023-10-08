import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import '../bluetooth/modelResult.dart';
import 'model/bike_model.dart';

showTextToast(String msg) {
  SmartDialog.showToast("",
      widget: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
            child: Text(
              msg,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
        ),
      )
  );
}
