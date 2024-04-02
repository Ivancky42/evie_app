import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
import '../../../api/backend/server_api_base.dart';
import '../../../api/dialog.dart';
import '../../../api/provider/auth_provider.dart';
import '../../../api/snackbar.dart';
import '../../../widgets/evie_textform.dart';
import '../../onboarding_addNewBike/activate-evsecure.dart';

class ActivateEVWithCode extends StatefulWidget{
  final BuildContext bContext;
  const ActivateEVWithCode({Key? key, required this.bContext}) : super(key: key);

  @override
  State<ActivateEVWithCode> createState() => _ActivateEVWithCodeState();
}

class _ActivateEVWithCodeState extends State<ActivateEVWithCode> {

  late BikeProvider _bikeProvider;
  late PlanProvider _planProvider;
  late SettingProvider _settingProvider;
  late CurrentUserProvider _currentUserProvider;
  PriceModel? currentPriceModel;
  late final FocusNode _nameFocusNode;
  late AuthProvider _authProvider;

  _ActivateEVWithCodeState() : _nameFocusNode = FocusNode();
  final TextEditingController _bikeNameController = TextEditingController();

  bool enabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _nameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    //_nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _planProvider = Provider.of<PlanProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    final _formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top:0, bottom: EvieLength.target_reference_button_b),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: Platform.isIOS ? EdgeInsets.zero : EdgeInsets.only(top: 0),
                        child: AppBar(
                          systemOverlayStyle: SystemUiOverlayStyle.dark,
                          leading: IconButton(
                            icon: SvgPicture.asset('assets/buttons/back_big.svg', width: 24.w, height: 24.w,),
                            onPressed: () {
                              _settingProvider.changeSheetElement(SheetList.addPlan);
                            },
                          ),
                          centerTitle: true,
                          title: Text(
                            "Activate EV-Secure", style: EvieTextStyles.h2.copyWith(color: EvieColors.mediumBlack),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24.h, bottom: 14.h, left: 16.w, right: 16.w),
                        child: Text(
                          "If you purchased EV-Secure on our web store, you will have received an email containing a unique EV-Secure code.",
                          style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                          child: EvieTextFormField(
                            controller: _bikeNameController,
                            obscureText: false,
                            keyboardType: TextInputType.name,
                            hintText: "Enter your unique EV-Secure code",
                            labelText: "EV-Secure Code",
                            focusNode: _nameFocusNode,
                            enabled: enabled,
                            inputFormatter: [
                              MaskTextInputFormatter(mask: '#### #### #### ####', filter: { "#": RegExp(r'^[a-zA-Z0-9]+$') }),
                              UppercaseTextInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid EV-Secure Code';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w),
                    child: EvieButton(
                        width: double.infinity,
                        child: Text(
                          "Activate EV-Secure",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: enabled ? () async {
                          if (_formKey.currentState!.validate()) {
                            bool isConnected = false;
                            var connectivityResult = await (Connectivity().checkConnectivity());
                            if (connectivityResult == ConnectivityResult.mobile) {
                              // connected to a mobile network.
                              isConnected = true;
                            } else if (connectivityResult == ConnectivityResult.wifi) {
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
                              setState(() {
                                enabled = false;
                              });

                              showCustomLightLoading();
                              String redeemCode = _bikeNameController.text
                                  .replaceAll(" ", "");
                              LinkedHashMap<
                                  String,
                                  String> respond = await _planProvider
                                  .redeemEVSecureCode(redeemCode);
                              if (respond['result'] == 'CODE_NOT_FOUND') {
                                SmartDialog.dismiss(status: SmartStatus
                                    .loading);
                                showInvalidEVSecureCode();
                                setState(() {
                                  enabled = true;
                                });
                              }
                              else if (respond['result'] == 'CODE_REDEEMED') {
                                SmartDialog.dismiss(
                                    status: SmartStatus.loading);
                                showCodeRedeemedDialog(context);
                                setState(() {
                                  enabled = true;
                                });
                              }
                              else if (respond['result'] == 'CODE_AVAILABLE') {
                                String docId = respond['docId']!;
                                String orderId = respond['orderId']!;
                                String sentEmail = respond['sentEmail']!;
                                _authProvider.getIdToken().then((idToken) {
                                  if (idToken != null) {
                                    String auth = idToken;
                                    const header = Headers.jsonContentType;
                                    final body = {
                                      "productId": "prod_P6emdafBd0FyB0",
                                      "deviceIMEI": _bikeProvider
                                          .currentBikeModel?.deviceIMEI,
                                      //"created": (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
                                      "isExtend": _bikeProvider
                                          .currentBikePlanModel != null
                                          ? true
                                          : false,
                                      "created": _bikeProvider
                                          .currentBikePlanModel != null
                                          ? ((_bikeProvider
                                          .currentBikePlanModel!.expiredAt!
                                          .toDate().millisecondsSinceEpoch /
                                          1000).floor())
                                          : (DateTime
                                          .now()
                                          .millisecondsSinceEpoch / 1000)
                                          .floor(),
                                      "feature": 'EV-Secure',
                                      "orderId": orderId.toString(),
                                    };

                                    String base_url = 'https://us-central1-evie-126a6.cloudfunctions.net/shopify_evsecure/activateEVSecure';
                                    ServerApiBase.postRequest(
                                        auth, base_url, body, header).then((
                                        value) {
                                      SmartDialog.dismiss(
                                          status: SmartStatus.loading);
                                      FirebaseFirestore.instance.collection(
                                          "codes").doc(redeemCode).update({
                                        "available": false,
                                        "redeemedBy": _authProvider.getUid,
                                        "redeemed": true,
                                      }).then((value) {
                                        return {
                                          showEVSecureActivatedInToast(
                                              "EV-Secure Activated!"),
                                          Future.delayed(
                                              const Duration(seconds: 2), () {
                                            changeToUserHomePageScreen(context);
                                            if (_bikeProvider.isPlanSubscript ==
                                                true) {
                                              showThankyouDialog(context);
                                            }
                                            else {
                                              showWelcomeToEVClub(context);
                                            }
                                          })
                                        };
                                      });
                                    });
                                  }
                                });
                              }
                              else {
                                print('hello');
                              }
                            }
                          }
                        } : null,
                    )
                  )
                ]
            ),
          )
      )
    );
  }

  String formatCurrency(double amount) {
    // Create a NumberFormat instance for Euro currency
    NumberFormat euroFormat = NumberFormat.simpleCurrency(locale: 'en', name: '€');

    // Format the amount with Euro currency symbol
    return euroFormat.format(amount/100);
  }
}
