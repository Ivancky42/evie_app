import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api/backend/stripe_api_caller.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/length.dart';
import '../../../../api/model/plan_model.dart';
import '../../../../api/model/price_model.dart';
import '../../../../api/navigator.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/setting_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../api/snackbar.dart';
import '../../../../api/toast.dart';
import '../../../../widgets/evie_appbar.dart';
import '../../../../widgets/evie_button.dart';
import '../../../../widgets/evie_container.dart';

class ProPlan2 extends StatefulWidget{
  const ProPlan2({Key? key}) : super(key: key);

  @override
  State<ProPlan2> createState() => _ProPlan2State();
}

class _ProPlan2State extends State<ProPlan2> {

  late BikeProvider _bikeProvider;
  late PlanProvider _planProvider;
  late SettingProvider _settingProvider;
  late CurrentUserProvider _currentUserProvider;
  PriceModel? currentPriceModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _planProvider = Provider.of<PlanProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    if (_planProvider.priceList.isNotEmpty) {
      currentPriceModel = _planProvider.priceList.values.elementAt(0);
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold (
          backgroundColor: EvieColors.grayishWhite,
          appBar: PageAppbar(
          title: _bikeProvider.isPlanSubscript == false  ? 'Add EV-Secure' : "EV+",
          onPressed: () {
            _settingProvider.changeSheetElement(SheetList.currentPlan);
          },
          ),
          body: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top:24.5.h),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Container(
                height: 664.h,
                width: 326.w,
                decoration: BoxDecoration(
                    color: EvieColors.dividerWhite,
                    border: Border.all(
                      color: EvieColors.dividerWhite,
                    ),
                    boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 10.0.w,
                    blurRadius: 10.0.w,
                  ),
                ], borderRadius: BorderRadius.all(Radius.circular(10))),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 16.w, left: 16.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 24.h, bottom: 44.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "EV-Secure",
                                    style: EvieTextStyles.h1.copyWith(fontWeight: FontWeight.w800),
                                  ),

                                SizedBox(width: 4.w),
                                SvgPicture.asset(
                                  "assets/icons/antitheft_2.svg",
                                  width: 36.w,
                                  height: 36.w,
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                  child: SvgPicture.asset(
                                    "assets/icons/location_icon.svg",
                                    height: 36.h,
                                    width: 36.w,
                                  ),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GPS Tracking',
                                        style: EvieTextStyles.target_reference_body,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: Text(
                                          "Track your bike's location remotely and be notified when it moves from its parked spot.",
                                          textAlign: TextAlign.left,
                                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8.w, 0, 12.w, 0),
                                  child: SvgPicture.asset(
                                    "assets/icons/notification_icon.svg",
                                    height: 23.23.h,
                                    width: 36.w,
                                  ),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Instant Alert Notifications',
                                        style: EvieTextStyles.target_reference_body,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: Text(
                                          "Stay informed around the clock with lightning-fast alerts and secure cloud communication for your bike.",
                                          textAlign: TextAlign.left,
                                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h,),
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8.w, 0, 16.w, 0),
                                  child: SvgPicture.asset(
                                    "assets/icons/bar_icon.svg",
                                    height: 27.w,
                                    width: 36.w,
                                  ),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ride History',
                                        style: EvieTextStyles.target_reference_body,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: Text(
                                          "Discover your past adventures with Ride History, a journey through time.",
                                          textAlign: TextAlign.left,
                                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h,),
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8.w, 0, 12.w, 0),
                                  child: SvgPicture.asset(
                                    "assets/icons/share_icon.svg",
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bike Sharing',
                                        style: EvieTextStyles.target_reference_body,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: Text(
                                          "Share your bike with up to 4 friends and family.",
                                          textAlign: TextAlign.left,
                                          style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                    Column(
                      children: [
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.mediumLightBlack),
                              children: [
                                TextSpan(
                                  text: "€5",
                                  style: TextStyle(fontWeight: FontWeight.bold), // Making "€" bold
                                ),
                                TextSpan(text: "/month for a year."),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _bikeProvider.isPlanSubscript! == false ||
                              (calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) >= 0),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.w,7.h,16.w, 24.h),
                            child:  EvieButton(
                              width: double.infinity,
                              height: 48.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_bikeProvider.isPlanSubscript == false  ? "Upgrade Now" :
                                  calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) >= 0 ?"Extend My EV-Secure" :
                                  "Extend My EV-Secure",
                                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                                  ),
                                  SizedBox(width: 4.w,),
                                  SvgPicture.asset(
                                    "assets/buttons/external_link.svg",
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                if(_bikeProvider.isOwner == true){
                                  _settingProvider.changeSheetElement(SheetList.addPlan);
                                }
                                else{
                                  showNoPermissionForEVSecureToast(context);
                                }

                                // String key = _planProvider.availablePlanList.keys.elementAt(0);
                                // PlanModel planModel = _planProvider.availablePlanList[key];
                                // String priceKey = _planProvider.priceList.keys.elementAt(0);
                                // PriceModel priceModel = _planProvider.priceList[priceKey];
                                //
                                // String testPlanId = "prod_NYoaq2Ij02Tm9H";
                                // String testPriceId = 'price_1MoLATIXKqdv4F5CxoQLwFhf';
                                // _planProvider.purchasePlan(_bikeProvider.currentBikeModel!.deviceIMEI!, planModel.id!, priceModel.id).then((value) {
                                //   // _planProvider.purchasePlan(_bikeProvider.currentBikeModel!.deviceIMEI!, planModel.id!, priceModel.id).then((value) {
                                //   if (value == 'NO_SUCH_CUSTOMER') {
                                //     _planProvider.createAndUpdateStripeCustomer()
                                //         .then((value) {
                                //       if (value == 'success') {
                                //         _planProvider.purchasePlan(
                                //             _bikeProvider.currentBikeModel!
                                //                 .deviceIMEI!, planModel.id!,
                                //             priceModel.id).then((value) {
                                //           if (value == 'NO_SUCH_CUSTOMER') {
                                //             showTextToast('NO_SUCH_CUSTOMER_ID');
                                //           }
                                //           else {
                                //             changeToStripeCheckoutScreen(
                                //                 context, value,
                                //                 _bikeProvider.currentBikeModel!,
                                //                 planModel,
                                //                 priceModel);
                                //           }
                                //         });
                                //       }
                                //     });
                                //   }
                                //   else {
                                //     changeToStripeCheckoutScreen(context, value,
                                //         _bikeProvider.currentBikeModel!, planModel,
                                //         priceModel);
                                //   }
                                // });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
                ),
              ),
            ],
          ),
          ),
      ),
    );
  }

  String formatCurrency(double amount) {
    // Create a NumberFormat instance for Euro currency
    NumberFormat euroFormat = NumberFormat.simpleCurrency(locale: 'en', name: '€');

    // Format the amount with Euro currency symbol
    return euroFormat.format(amount/100);
  }
}
