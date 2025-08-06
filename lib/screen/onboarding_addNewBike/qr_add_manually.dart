

import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../api/navigator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_text_input_formatter.dart';
import '../../widgets/evie_textform.dart';

class QRAddManually extends StatefulWidget {
  const QRAddManually({super.key});

  @override
  _QRAddManuallyState createState() => _QRAddManuallyState();
}

class _QRAddManuallyState extends State<QRAddManually> {

  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _validationKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;

  int currentPageNumber = 4;

  late final FocusNode _nameFocusNode;

  _QRAddManuallyState() : _nameFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameFocusNode.requestFocus();
  }


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 59.h, 20.w, 16.h),
                          child:   GestureDetector(
                            onTap: (){
                              _authProvider.setIsFirstLogin(false);
                              _bikeProvider.setIsAddBike(false);
                              showEvieExitRegistrationDialog(context);
                            },
                            child: SvgPicture.asset(
                              "assets/buttons/close_black.svg",
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w,4.h),
                      child: Text(
                        "Please enter the following codes. "
                            "You'll find them next to the QR code on the back of your manual.",
                        style: EvieTextStyles.body18.copyWith(height: 1.5.h),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(11.w,4.h,16.w,12.h),
                      child: TextButton(
                        onPressed: (){
                          showEvieFindSerialDialog(context);
                        },
                        child: Text("Where to find these?",
                          style: EvieTextStyles.body18.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 8.h),
                      child: EvieTextFormField(
                        inputFormatter: [AddQRInputFormatter()],
                        controller: _serialNumberController,
                        obscureText: false,
                        hintText: "T0AS01 0101 000001",
                        labelText: "Serial Number",
                        focusNode: _nameFocusNode,
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
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),
                      onPressed: () async {
                if (_formKey.currentState!.validate()) {

                  ///For keyboard un focus
                  FocusManager.instance.primaryFocus?.unfocus();

                  String code =
                      "serialNumber:${_serialNumberController.text.trim().replaceAll(" ", "")},"
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
