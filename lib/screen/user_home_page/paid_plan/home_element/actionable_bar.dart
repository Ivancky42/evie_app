import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/dialog.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/fonts.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../api/sheet_2.dart';
import '../../../../widgets/actionable_bar.dart';
import '../../../../widgets/evie_card.dart';
import '../../home_page_widget.dart';


class ActionableBarHome extends StatefulWidget {
  ActionableBarHome({
    Key? key
  }) : super(key: key);

  @override
  State<ActionableBarHome> createState() => _ActionableBarHomeState();
}

class _ActionableBarHomeState extends State<ActionableBarHome> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  String? pageNavigate;

  DeviceConnectResult? deviceConnectResult;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    if(deviceConnectResult == DeviceConnectResult.connected && _bikeProvider.currentBikeModel?.macAddr == _bluetoothProvider.currentConnectedDevice){
      Future.delayed(Duration.zero, () {
        if(pageNavigate != null){
          switch(pageNavigate){
            case "registerEVKey":
              pageNavigate = null;
                _settingProvider.changeSheetElement(SheetList.evKey);
                showSheetNavigate(context);
              break;
          }
        }
      });
    }

    switch(_bikeProvider.actionableBarItem){
      case ActionableBarItem.none:
        return SizedBox.shrink();

      case ActionableBarItem.registerEVKey:
        return EvieActionableBar(
          icon:   SvgPicture.asset(
            "assets/icons/register_evKey.svg",
          ),
          title: 'Register EV-Key',
          text: 'Add EV-Key to unlock your bike without app assistance.',
          backgroundColor: EvieColors.primaryColor,
          onTap: () {
            if (deviceConnectResult == null
                || deviceConnectResult == DeviceConnectResult.disconnected
                || deviceConnectResult == DeviceConnectResult.scanTimeout
                || deviceConnectResult == DeviceConnectResult.connectError
                || deviceConnectResult == DeviceConnectResult.scanError
                || _bikeProvider.currentBikeModel?.macAddr != _bluetoothProvider.currentConnectedDevice
            ) {
              setState(() {
                pageNavigate = 'registerEVKey';
              });
              showConnectBluetoothDialog(context, _bluetoothProvider, _bikeProvider);
             // showEvieActionableBarDialog(context, _bluetoothProvider, _bikeProvider);
            }
            else if (deviceConnectResult == DeviceConnectResult.connected) {
                _settingProvider.changeSheetElement(SheetList.evKey);
                showSheetNavigate(context);
            }
          },
        );
    }
  }

}


