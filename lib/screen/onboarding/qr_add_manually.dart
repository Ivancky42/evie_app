
import 'dart:async';

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../api/provider/bluetooth_provider.dart';
import '../../widgets/evie_textform.dart';
import 'bike_connect_failed.dart';
import 'bike_connect_success.dart';


class QRAddManually extends StatefulWidget {
  const QRAddManually({Key? key}) : super(key: key);

  @override
  _QRAddManuallyState createState() => _QRAddManuallyState();
}

class _QRAddManuallyState extends State<QRAddManually> {


  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _validationKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late BikeProvider _bikeProvider;


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
          body: Stack(
              children:[
              Form(
              key: _formKey,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(70.w, 66.h, 70.w,50.h),
                      child:const StepProgressIndicator(
                        totalSteps: 10,
                        currentStep: 3,
                        selectedColor: Color(0xffCECFCF),
                        selectedSize: 4,
                        unselectedColor: Color(0xffDFE0E0),
                        unselectedSize: 3,
                        padding: 0.0,
                        roundedEdges: Radius.circular(16),
                      ),
                    ),



                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                      child: Text(
                        "Please enter the following codes. "
                            "You'll find them next to the QR code on the back of your manual.",
                        style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                      ),
                    ),


                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                      child: EvieTextFormField(
                        controller: _serialNumberController,
                        obscureText: false,
                        hintText: "T0AS01010100001",
                        labelText: "Serial Number",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter serial number';
                          }
                          return null;
                        },
                      ),
                    ),


                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                      child: EvieTextFormField(
                        controller: _validationKeyController,
                        obscureText: false,
                        hintText: "000000",
                        labelText: "Validation Key",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter validation key';
                          }
                          return null;
                        },
                      ),
                    ),

                  ],
                ),

              ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.button_Bottom),
                    child:  EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Validate Code",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: () async {

                if (_formKey.currentState!.validate()) {
                  String code =
                      "serialNumber:${_serialNumberController.text.trim()},"
                      "validationKey:${_validationKeyController.text.trim()}";

                  await _bikeProvider.handleBarcodeData(code);

                  if(_bikeProvider.scanQRCodeResult == ScanQRCodeResult.success){
                   changeToBikeConnectSuccessScreen(context);
                  }else{
                    changeToBikeConnectFailedScreen(context);
                  }


                }
                      },
                    ),
                  ),

              ),
              ]
          )
      ),
    );
  }
}
