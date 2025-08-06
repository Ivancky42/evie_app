import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/snackbar.dart';
import '../../../widgets/evie_textform.dart';



class NameEV extends StatefulWidget {
  //final String rfidNumber;

  const NameEV(
      //this.rfidNumber,
      {super.key});

  @override
  _NameEVState createState() => _NameEVState();
}

class _NameEVState extends State<NameEV> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  final TextEditingController _rfidNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);


    return SizedBox(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 18.h),
                    child: Container(
                      width: 25.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: EvieColors.progressBarGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Padding(
                    padding: EdgeInsets.only(top: 18.h),
                    child: Container(
                      width: 25.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: EvieColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 2.h),
                child: Text(
                  "Label your EV-Key",
                  style: TextStyle(
                      fontSize: 24.sp, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 11.h),
                child: Text(
                  "Personalize your EV-Key with a unique name that sets it apart from the rest.",
                  style: TextStyle(fontSize: 16.sp, height: 1.5.h),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                child: EvieTextFormField(
                  controller: _rfidNameController,
                  obscureText: false,
                  focusNode: _nameFocusNode,
                  // keyboardType: TextInputType.name,
                  hintText: "Name your EV-Key",
                  labelText: "EV-Key Label",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter EV-Key name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 140.h, 16.w, EvieLength.buttonWord_WordBottom),
            child: Column(
              children: [
                SizedBox(
                  height: 48.h,
                  width: double.infinity,
                  child: EvieButton(
                    width: double.infinity,
                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () async {
                      ///For keyboard un focus
                      FocusManager.instance.primaryFocus?.unfocus();
                      addRFIDtoFireStore(_rfidNameController.text.trim());
                      _settingProvider.changeSheetElement(SheetList.evKeyList);
                    },
                  ),
                ),

                SizedBox(height: 15.h,),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Can't think of any name now",
                      softWrap: false,
                      style: EvieTextStyles.body18_underline,
                    ),
                    onPressed: () {
                      _settingProvider.changeSheetElement(SheetList.evKeyList);
                      // if(_bikeProvider.rfidList.length >0){
                      //   _settingProvider.changeSheetElement(SheetList.evKeyList);
                      // }else{
                      //   showBikeSettingSheet(context);
                      // }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      //color: Colors.red,
    );
  }

  void addRFIDtoFireStore(String rfidName) async {
    final result = await _bikeProvider.uploadRFIDtoFireStore(_settingProvider.stringPassing!, rfidName);
    if (result == true) {
      showSuccessAddEVKey(context);
    } else {
      showFailAddEVKey(context);
    }
  }
}
