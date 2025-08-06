
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../animation/waved_curves_animation.dart';
import '../../api/length.dart';
import '../../bluetooth/modelResult.dart';
import 'home_page_widget.dart';

class BatteryDetails extends StatefulWidget {


  const BatteryDetails({
    super.key,

  });

  @override
  State<BatteryDetails> createState() => _BatteryDetailsState();
}

class _BatteryDetailsState extends State<BatteryDetails> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return Material(
      child: WillPopScope(
        onWillPop: () async {
           return true;
        },

        child: Container(
          color: EvieColors.grayishWhite,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                    EdgeInsets.only(left: 17.w, top: 0.h, bottom: 11.h),
                    child: Text(
                      "Battery",
                      style: EvieTextStyles.target_reference_h1,
                    ),
                  ),

                ],
              ),

              const Divider(
                thickness: 2,
              ),
              SizedBox(height: 30.h,),
              Stack(
                children: [
                  SizedBox(
                    height: 220.h,
                    width: double.infinity,
                    child: WavedCurvesAnimation(),
                  ),
                  SizedBox(
                    height: EvieLength.battery_curved_bottom - 35.h,
                    //color: Colors.green,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 16.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "${_bikeProvider.currentBikeModel?.batteryModel?.percentage ?? 0}%",
                          //   style: EvieTextStyles.batteryPercent.copyWith(color: EvieColors.lightBlack),
                          // ),
                          Text(
                            "${_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected ?
                            int.parse(_bluetoothProvider.bikeInfoResult?.batteryLevel ?? "0") :
                            _bikeProvider.currentBikeModel?.batteryModel?.percentage ?? 0}%",
                            style: EvieTextStyles.batteryPercent.copyWith(color: EvieColors.lightBlack),
                          ),
                          Text(
                            "Estimate ${getEstDistance(_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected ?
                            int.parse(_bluetoothProvider.bikeInfoResult?.batteryLevel ?? "0") :
                            _bikeProvider.currentBikeModel?.batteryModel?.percentage ?? 0, _settingProvider)} remaining",
                            style: EvieTextStyles.body16,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              Padding(
                padding: EdgeInsets.only(left:16.w, right: 16.w, top: 6.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Model", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),),
                    Text(_bikeProvider.currentBikeModel?.batteryModel?.model ?? '-', style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),),

                    Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      child: EvieDivider(),
                    ),


                    Text("Battery Capacity", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),),
                    Text("365 Wh", style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),),

                    Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      child: EvieDivider(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          //height: 750.h,
        ),
      ),
    );
  }
}
