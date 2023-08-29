
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/function.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../widgets/evie_radio_button.dart';
import '../../../widgets/evie_switch.dart';
import '../../animation/waved_curves_animation.dart';
import '../../api/length.dart';

class BatteryDetails extends StatefulWidget {


  BatteryDetails({
    Key? key,

  }) : super(key: key);

  @override
  State<BatteryDetails> createState() => _BatteryDetailsState();
}

class _BatteryDetailsState extends State<BatteryDetails> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;

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
    _locationProvider = Provider.of<LocationProvider>(context);

    return Material(
      child: WillPopScope(
        onWillPop: () async {
          bool shouldClose = true;
          await showDialog<void>(
              context: context,
              builder: (BuildContext context) =>
                  EvieDoubleButtonDialog(
                      title: "Close this sheet?",
                      childContent: Text("Are you sure you want to close this sheet?",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),),
                      leftContent: "No",
                      rightContent: "Yes",
                      onPressedLeft: () {
                        shouldClose = false;
                        Navigator.of(context).pop();
                      },
                      onPressedRight: () {
                        shouldClose = true;
                        Navigator.of(context).pop();
                      }));
          return shouldClose;
        },

        child: Container(
          decoration: const BoxDecoration(
            color: EvieColors.grayishWhite,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Padding(
              //   padding:  EdgeInsets.only(top: 13.h),
              //   child: SvgPicture.asset(
              //     "assets/buttons/down.svg",
              //   ),
              // ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                    EdgeInsets.only(left: 17.w, top: 0.h, bottom: 11.h),
                    child: Text(
                      "Battery",
                      style: EvieTextStyles.h1,
                    ),
                  ),

                ],
              ),

              const Divider(
                thickness: 2,
              ),

              Stack(
                children: [
                      Container(
                      height: 220.h,
                      width: double.infinity,
                      child: WavedCurvesAnimation(),
                    ),

                  Container(
                    height: EvieLength.battery_curved_bottom-30.h,
                    child: Padding(
                      padding: EdgeInsets.only(left:16.w, right: 16.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_bikeProvider.currentBikeModel?.batteryModel?.percentage ?? 0}%", style: EvieTextStyles.batteryPercent.copyWith(color: EvieColors.lightBlack),),
                          Text("Estimate -km remaining", style: EvieTextStyles.body16,),
                      ],
                      ),
                    ),
                  )
                ],
              ),

              Padding(
                padding: EdgeInsets.only(left:16.w, right: 16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Model", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),),
                    Text("S1 A1C2-E345", style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),),

                    Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      child: EvieDivider(),
                    ),

                    Text("Battery Life", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),),
                    Text("Lorem Lpsum", style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),),

                    Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      child: EvieDivider(),
                    ),

                    Text("Battery Capacity", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),),
                    Text("1,234 Wh", style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),),

                    Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      child: EvieDivider(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          height: 750.h,
        ),
      ),
    );
  }
}
