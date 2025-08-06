import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/enumerate.dart';
import '../../../api/model/plan_model.dart';
import '../../../api/model/price_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/provider/plan_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/toast.dart';
import '../../../widgets/evie_appbar.dart';

class AddPlan extends StatefulWidget {
  const AddPlan({super.key});

  @override
  State<AddPlan> createState() => _AddPlanState();
}

class _AddPlanState extends State<AddPlan> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late SettingProvider _settingProvider;
  late PlanProvider _planProvider;


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _planProvider = Provider.of<PlanProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // _settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: _bikeProvider.isPlanSubscript == false  ? 'Upgrade to EV-Secure' : "Extend My EV-Secure",
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.proPlan);
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 19.h),
              child: Text(
                "Secure your ride with 24/7 protection from EV-Secure.",
                style: EvieTextStyles.body18,
              ),
            ),
            Container(
              width: double.infinity,
              height: 25.h,
              color: EvieColors.dividerWhite,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w),
                child: Text(
                  "Choose an option",
                  style: EvieTextStyles.caption,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _settingProvider.changeSheetElement(SheetList.activateEVWithCode);
              },
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Activate with code",
                                style: EvieTextStyles.body18,
                              ),
                              SizedBox(height: 4.h,),
                              Text(
                                "Have an EV-Secure code? Choose this option.",
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                              ),
                            ],
                          ),
                          Center(
                            child: SvgPicture.asset(
                              "assets/buttons/next.svg",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Divider(
                            thickness: 0.2.h,
                            color: EvieColors.darkWhite,
                            height: 0,
                          ),
                        )
                    ),
                  ],
                ),
              )
            ),
            GestureDetector(
              onTap: () async {
                bool isConnected = false;
                var connectivityResult = await (Connectivity()
                    .checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile) {
                  // connected to a mobile network.
                  isConnected = true;
                } else
                if (connectivityResult == ConnectivityResult.wifi) {
                  // connected to a wifi network.
                  isConnected = true;
                } else {
                  // not connected to any network.
                  isConnected = false;
                }

                if (!isConnected) {
                  showNoInternetConnection();
                }
                else {
                  showCustomLightLoading();
                  String key = _planProvider.availablePlanList.keys.elementAt(
                      0);
                  PlanModel planModel = _planProvider.availablePlanList[key];
                  String priceKey = _planProvider.priceList.keys.elementAt(0);
                  PriceModel priceModel = _planProvider.priceList[priceKey];

                  String testPlanId = "prod_NYoaq2Ij02Tm9H";
                  String testPriceId = 'price_1MoLATIXKqdv4F5CxoQLwFhf';
                  _planProvider.purchasePlan(
                      _bikeProvider.currentBikeModel!.deviceIMEI!,
                      planModel.id!, priceModel.id).then((value) {
                    // _planProvider.purchasePlan(_bikeProvider.currentBikeModel!.deviceIMEI!, planModel.id!, priceModel.id).then((value) {
                    SmartDialog.dismiss(status: SmartStatus.loading);
                    if (value == 'NO_SUCH_CUSTOMER') {
                      _planProvider.createAndUpdateStripeCustomer()
                          .then((value) {
                        if (value == 'success') {
                          _planProvider.purchasePlan(
                              _bikeProvider.currentBikeModel!
                                  .deviceIMEI!, planModel.id!,
                              priceModel.id).then((value) {
                            if (value == 'NO_SUCH_CUSTOMER') {
                              showTextToast('NO_SUCH_CUSTOMER_ID');
                            }
                            else {
                              changeToStripeCheckoutScreen(
                                  context, value,
                                  _bikeProvider.currentBikeModel!,
                                  planModel,
                                  priceModel);
                            }
                          });
                        }
                      });
                    }
                    else {
                      changeToStripeCheckoutScreen(context, value,
                          _bikeProvider.currentBikeModel!, planModel,
                          priceModel);
                    }
                  });
                }
              },
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upgrade with App",
                                style: EvieTextStyles.body18,
                              ),
                              SizedBox(height: 4.h,),
                              SizedBox(
                                width: 318.w,
                                child: Text(
                                  "Want to upgrade directly through app? Choose this option.",
                                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                ),
                              )
                            ],
                          ),
                          Center(
                            child: SvgPicture.asset(
                              "assets/buttons/next.svg",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Divider(
                            thickness: 0.2.h,
                            color: EvieColors.darkWhite,
                            height: 0,
                          ),
                        )
                    ),
                  ],
                ),
              )
            )
          ],
        )
      ),
    );
  }
}
