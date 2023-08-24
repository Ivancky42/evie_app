
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

import '../../../../api/colours.dart';
import '../../../../api/length.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';

class DeactivateTheftAlert extends StatefulWidget {
  DeactivateTheftAlert({
    Key? key,

  }) : super(key: key);

  @override
  State<DeactivateTheftAlert> createState() => _DeactivateTheftAlertState();
}

class _DeactivateTheftAlertState extends State<DeactivateTheftAlert> {

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
      child: Container(
        height: 100.h,
        decoration: const BoxDecoration(
          color: EvieColors.grayishWhite,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Padding(
              padding:
              EdgeInsets.only(left: 0.w, top: 0.h, bottom: 0.h),
              child: GestureDetector(

                onTap: (){
                  Navigator.pop(context);
                  showDeactivateTheftDialog(context, _bikeProvider);
                },
                child: Container(
                  height: 100.h,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 18.w, right: 8.w),
                    leading:  SvgPicture.asset(
                      "assets/icons/alert_black.svg",
                    ),

                    title: Padding(
                      padding: EdgeInsets.only(top:10.h),
                      child: Row(
                        children: [
                          Text(
                            "Deactivate Theft Alert",
                            style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
                          ),

                        ],
                      ),
                    ),
                    subtitle: Wrap(
                      children: [
                        Text(
                        "Clear the Theft Attempt Mode and revert your bike to its default state until it is triggered again.",
                        style: EvieTextStyles.body14.copyWith(fontWeight: FontWeight.bold, color: EvieColors.darkGrayishCyan),
                      ),
                      ]
                    ),
                    trailing: SvgPicture.asset(
                      "assets/buttons/next.svg",
                    ),
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
