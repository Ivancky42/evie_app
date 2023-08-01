
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
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
          await showCupertinoDialog<void>(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text('Should Close?'),
                actions: <Widget>[
                  CupertinoButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      shouldClose = true;
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('No'),
                    onPressed: () {
                      shouldClose = false;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
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
                    //   Container(
                    //   height: 500.h,
                    //   width: double.infinity,
                    //   child: WavedCurvesAnimation(),
                    // ),
                ],
              ),
              Text("Model"),
              Text("Battery Life"),
              Text("Any Other Information"),
            ],
          ),
          height: 750.h,
        ),
      ),
    );
  }
}
