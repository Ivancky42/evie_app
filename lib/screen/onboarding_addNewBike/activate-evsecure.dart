import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/api/provider/auth_provider.dart' as auth;
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import '../../api/backend/server_api_base.dart';
import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import 'package:evie_test/widgets/evie_button.dart';
import '../../api/provider/bike_provider.dart';
import '../../api/snackbar.dart';
import '../../widgets/evie_progress_indicator.dart';
import '../../widgets/evie_textform.dart';

class ActivateEVSecureScreen extends StatefulWidget {
  final String bikeName;
  const ActivateEVSecureScreen({super.key, required this.bikeName});

  @override
  _ActivateEVSecureScreenState createState() => _ActivateEVSecureScreenState();
}

class _ActivateEVSecureScreenState extends State<ActivateEVSecureScreen> {

  late auth.AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late PlanProvider _planProvider;
  late final FocusNode _nameFocusNode;

  _ActivateEVSecureScreenState() : _nameFocusNode = FocusNode();
  final TextEditingController _bikeNameController = TextEditingController();

  bool enabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authProvider = context.read<auth.AuthProvider>();
    _bikeProvider = context.read<BikeProvider>();
    _planProvider = context.read<PlanProvider>();
    _nameFocusNode.requestFocus();
  }

  // @override
  // void dispose() {
  //   _nameFocusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    final formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        body: Stack(
          children: [
            Form(
              key: formKey,
              child:Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    const EvieProgressIndicator(currentPageNumber: 4, totalSteps: 6,),

                    Text(
                      "Activate EV+ Subscription",
                      style: EvieTextStyles.h2,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text("Did you purchase EV-Secure together with ${widget.bikeName}? Enter your EV-Secure code to activate.",
                      style: EvieTextStyles.body18,),

                    SizedBox(
                      height: 1.h,
                    ),

                    TextButton(
                      child: Text(
                        "Where do I find my EV-Secure code?",
                        softWrap: false,
                        style: EvieTextStyles.body18_underline,
                      ),
                      onPressed: () {
                        showWhereToFindEVSecureCode(context);
                      },
                    ),

                    SizedBox(
                      height: 2.h,
                    ),

                    EvieTextFormField(
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
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.buttonWord_ButtonBottom),
                child: EvieButton(
                    width: double.infinity,
                    onPressed: enabled ? () async {
                      if (formKey.currentState!.validate()) {
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
                          setState(() {
                            enabled = false;
                          });

                          String redeemCode = _bikeNameController.text
                              .replaceAll(" ", "");
                          LinkedHashMap<
                              String,
                              String> respond = await _planProvider
                              .redeemEVSecureCode(redeemCode);
                          if (respond['result'] == 'CODE_NOT_FOUND') {
                            SmartDialog.dismiss(status: SmartStatus.loading);
                            showInvalidEVSecureCode();
                            setState(() {
                              enabled = true;
                            });
                          }
                          else if (respond['result'] == 'CODE_REDEEMED') {
                            SmartDialog.dismiss(status: SmartStatus.loading);
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
                                  "deviceIMEI": _bikeProvider.currentBikeModel
                                      ?.deviceIMEI,
                                  "created": (DateTime
                                      .now()
                                      .millisecondsSinceEpoch / 1000).floor(),
                                  "feature": 'EV-Secure',
                                  "orderId": orderId.toString(),
                                };

                                String baseUrl = 'https://us-central1-evie-126a6.cloudfunctions.net/shopify_evsecure/activateEVSecure';
                                ServerApiBase.postRequest(
                                    auth, baseUrl, body, header).then((value) {
                                  SmartDialog.dismiss(
                                      status: SmartStatus.loading);
                                  FirebaseFirestore.instance.collection("codes")
                                      .doc(redeemCode).update({
                                    "available": false,
                                    "redeemedBy": _authProvider.getUid,
                                    "redeemed": true,
                                  })
                                      .then((value) {
                                    return {
                                      showEVSecureActivated(context),
                                      Future.delayed(
                                          const Duration(seconds: 3), () {
                                        changeToCongratsBikeAdded(
                                            context, widget.bikeName);
                                      }),
                                    };
                                  });
                                });
                              }
                            });
                          }
                        }
                      }
                    } : null,
                    child: Text(
                      "Activate EV-Secure",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                    )
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "I didn’t purchase a EV+ Subscription",
                      softWrap: false,
                      style: EvieTextStyles.body18_underline,
                    ),
                    onPressed: () {
                      if(_bikeProvider.isAddBike == true){
                        _bikeProvider.setIsAddBike(false);
                        ///TODO : change to activate EV-Secure Screen.
                        changeToCongratsBikeAdded(context, "EVIE ${_bikeProvider.currentBikeModel!.model!}");
                      }else{
                        // changeToTurnOnNotificationsScreen(context);
                        changeToCongratsBikeAdded(context, "EVIE ${_bikeProvider.currentBikeModel!.model!}");
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UppercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
