import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/function.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../bluetooth/modelResult.dart';

class EVAddFailed extends StatefulWidget {
  const EVAddFailed({Key? key}) : super(key: key);

  @override
  _EVAddFailedState createState() => _EVAddFailedState();
}

class _EVAddFailedState extends State<EVAddFailed> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;
  late BluetoothProvider _bluetoothProvider;
  DeviceConnectResult? deviceConnectResult;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;


    return WillPopScope(
      onWillPop: () async {
        //_settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(

        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
                  child: Text(
                    "Whoops! There's an issue.",
                    style: EvieTextStyles.h2.copyWith(color:EvieColors.mediumBlack),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                  child: Text(
                    "We're sorry, but there was an error registering your EV-Key.  \n\n"
                        "Make sure your EV-Key is fully touching the lock and try again.",
                    style: EvieTextStyles.body18.copyWith(color:EvieColors.lightBlack),
                  ),
                ),

                  Center(
                      child: Lottie.asset('assets/animations/error-animate.json', repeat: false)
                  ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,41.96.h,16.w, EvieLength.buttonButton_wordBottom),
                child:  EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                      "Try Again",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                  ),
                  onPressed: () {
                    if (deviceConnectResult == null
                        || deviceConnectResult == DeviceConnectResult.disconnected
                        || deviceConnectResult == DeviceConnectResult.scanTimeout
                        || deviceConnectResult == DeviceConnectResult.connectError
                        || deviceConnectResult == DeviceConnectResult.scanError
                        || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
                    ) {
                      _settingProvider.changeSheetElement(SheetList.registerEvKey);
                      showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
                      //showConnectDialog(_bluetoothProvider, _bikeProvider);
                    }
                    else if (deviceConnectResult == DeviceConnectResult.connected) {
                      _settingProvider.changeSheetElement(SheetList.registerEvKey);
                    }
                  },
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child:Padding(
                  padding: EdgeInsets.fromLTRB(16.w,25.h,16.w,EvieLength.buttonWord_ButtonBottom),
                  child: EvieButton_ReversedColor(
                      width: double.infinity,
                      onPressed: (){
                        const url = 'https://support.eviebikes.com/en-US';
                        final Uri _url = Uri.parse(url);
                        launch(_url);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Get Help", style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)),
                          SvgPicture.asset(
                            "assets/buttons/external_link.svg",
                          ),
                        ],
                      )
                  )
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonbutton_buttonBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Cancel register EV-Key",
                      softWrap: false,
                      style: EvieTextStyles.body14.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                      if(_bikeProvider.rfidList.length >0){
                        _settingProvider.changeSheetElement(SheetList.evKeyList);
                      }else{
                        showBikeSettingSheet(context);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),),
    );
  }
}
