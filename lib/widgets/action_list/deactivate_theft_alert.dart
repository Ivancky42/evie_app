
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
        height: 260.h,
        decoration: const BoxDecoration(
          color: EvieColors.grayishWhite,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                  showDeactivateTheftDialog(context, _bikeProvider);
                },
                child: Container(
                  //color: EvieColors.red,
                  height: 130.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/info.svg",
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              width: 263.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What Should I Do?",
                                    style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
                                  ),
                                  Flexible(
                                    child: Text(
                                      "Stay composed, take a breather. There's a list of suggested actions you might find helpful. Check it out!",
                                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SvgPicture.asset(
                            "assets/buttons/next.svg",
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ),
            ),

            Padding(
              padding: EdgeInsets.zero,
              child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                    showDeactivateTheftDialog(context, _bikeProvider);
                  },
                  child: Container(
                    //color: EvieColors.red,
                    height: 130.h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/alert_black.svg",
                              ),
                              SizedBox(width: 12.w),
                              Container(
                                width: 263.w,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "False Alarm?",
                                      style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Disable Theft Attempt Mode and revert your bike back to safe mode until it’s triggered again.",
                                        style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SvgPicture.asset(
                              "assets/buttons/next.svg",
                            ),
                          )
                        ],
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
