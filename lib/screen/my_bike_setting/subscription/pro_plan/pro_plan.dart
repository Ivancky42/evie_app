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
import '../../../../api/toast.dart';
import '../../../../widgets/evie_appbar.dart';
import '../../../../widgets/evie_button.dart';
import '../../../../widgets/evie_container.dart';

class ProPlan extends StatefulWidget{
  const ProPlan({Key? key}) : super(key: key);

  @override
  State<ProPlan> createState() => _ProPlanState();
}

class _ProPlanState extends State<ProPlan> {

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
      print('hello');
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold (
          backgroundColor: EvieColors.grayishWhite,
          appBar: PageAppbar(
          title: 'EV+',
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
                ],
                    // boxShadow:[
                    //   BoxShadow(
                    //     color: EvieColors.dividerWhite,
                    //     //spreadRadius: 2,
                    //     blurRadius: 24,
                    //     offset: Offset(0, 12),
                    //   ),
                    // ],
                    borderRadius:
                    BorderRadius.all(Radius.circular(10))),

                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 16.w, left: 16.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 24.h, bottom: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "EV-Secure",
                                    style: EvieTextStyles.body20.copyWith(color: EvieColors.darkGrayish),
                                  ),

                                SizedBox(width: 4.w),
                                SvgPicture.asset(
                                  "assets/icons/batch_tick.svg",
                                ),
                              ],
                            ),
                          ),


                          //Text("\$29.90",style: EvieTextStyles.display),
                          Text(
                              currentPriceModel != null ? formatCurrency(currentPriceModel!.unitAmount.toDouble()) : '-',
                              style: EvieTextStyles.display
                          ),

                          Align(
                              alignment: Alignment(0.4, -12),
                              child: Text("/per year",style: EvieTextStyles.body16.copyWith(color: EvieColors.darkGrayish),)),

                          Padding(
                            padding: EdgeInsets.only(top: 17.h, bottom: 16.h),
                            child:
                              Text(_bikeProvider.isPlanSubscript == false ?"":"You are currently on this plan.",
                                style: EvieTextStyles.body16.copyWith(color: EvieColors.primaryColor),),
                          ),

                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.only(left:16.w, right:16.w),
                            child: Text("Monitor your bike status remotely and receive security alerts.",
                              style: EvieTextStyles.body18.copyWith(
                                color: EvieColors.lightBlack,
                                height: 1.2.h,
                              ),
                            ),
                          ),



                          Padding(
                            padding: EdgeInsets.only(top: 14.h, bottom: 16.h),
                            child: Divider(height: 1.h,color: EvieColors.darkWhite,),
                          ),

                          Row(children: [
                            Text("Includes",style: EvieTextStyles.body18.copyWith(color: EvieColors.mediumLightBlack, fontWeight: FontWeight.bold),),
                          ]),

                          const PlanPageElementRow(content: "GPS tracking"),
                          const PlanPageElementRow(content: "Instant alert notifications"),
                          const PlanPageElementRow(content: "Theft Detection"),
                          const PlanPageElementRow(content: "Remote monitoring"),
                          const PlanPageElementRow(content: "Ride history"),
                          const PlanPageElementRow(content: "Bike Sharing"),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _bikeProvider.isPlanSubscript! == false ||
                          (calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) >= 0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, 24.h),
                          child:  EvieButton(
                            width: double.infinity,
                            height: 48.h,
                            child: Text(_bikeProvider.isPlanSubscript == false  ? "Upgrade Now" :
                                calculateDateDifferenceFromNow(_bikeProvider.currentBikePlanModel!.expiredAt!.toDate()) >= 0 ?"Renew Now" :
                                "See Plan Detail",
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                            ),
                            onPressed: () {
                              String key = _planProvider.availablePlanList.keys.elementAt(0);
                              PlanModel planModel = _planProvider.availablePlanList[key];
                              String priceKey = _planProvider.priceList.keys.elementAt(0);
                              PriceModel priceModel = _planProvider.priceList[priceKey];
                              _planProvider.purchasePlan(_bikeProvider.currentBikeModel!.deviceIMEI!, planModel.id!, priceModel.id).then((value) {
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
                            },
                          ),
                        ),
                      ),
                    ),],
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
