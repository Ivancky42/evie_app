import 'package:evie_bike/api/provider/bluetooth_provider.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../home_page_widget.dart';


class Status extends StatefulWidget {
  Status({
    Key? key
  }) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return EvieCard(
      onPress: (){
        showBatteryDetailsSheet(context);
      },

      title: "Status",
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(getCurrentBikeStatusIcon(_bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),
            height: 36.h, width:  36.w,),
            Text(getCurrentBikeStatusString(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected, _bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),
              style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray),
            ),
            SizedBox(height: 16.h,),
          ],
        ),
      ),

    );
  }
}


