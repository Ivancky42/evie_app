
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../animation/ripple_pulse_animation.dart';
import '../../api/backend/server_api_base.dart';
import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/model/bike_model.dart';
import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_progress_indicator.dart';

class BikeRegistering extends StatefulWidget {
  final bool isSuccess;
  final String? registeringDeviceIMEI;
  const BikeRegistering({Key? key, required this.isSuccess, this.registeringDeviceIMEI}) : super(key: key);

  @override
  _BikeRegisteringState createState() => _BikeRegisteringState();
}

class _BikeRegisteringState extends State<BikeRegistering> {

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _bikeProvider = context.read<BikeProvider>();
    // String? registeringDeviceIMEI = widget.registeringDeviceIMEI;
    // if (registeringDeviceIMEI != null) {
    //   FirebaseFirestore.instance.collection('bikes').doc(registeringDeviceIMEI).get().then((doc) {
    //     if (doc.exists){
    //       Map<String, dynamic>? obj = doc.data();
    //       BikeModel bikeModel = BikeModel.fromJson(obj!);
    //       if (bikeModel.pendingActivateEVSecure != null) {
    //         if (bikeModel.pendingActivateEVSecure!.enabled!) {
    //           _authProvider.getIdToken().then((idToken) {
    //             if (idToken != null) {
    //               String auth = idToken;
    //               const header = Headers.jsonContentType;
    //               final body = {
    //                 "productId": "prod_P6emdafBd0FyB0",
    //                 "deviceIMEI": bikeModel.deviceIMEI,
    //                 "created": (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
    //                 "feature": 'EV-Secure',
    //                 "orderId": bikeModel.pendingActivateEVSecure!.orderId,
    //               };
    //
    //               String base_url = 'https://us-central1-evie-126a6.cloudfunctions.net/shopify_evsecure/activateEVSecure';
    //               ServerApiBase.postRequest(auth, base_url, body, header).then((value) {
    //                 //print(value);
    //                 if (widget.isSuccess) {
    //                   changeToBikeConnectSuccessScreen(context);
    //                 }
    //                 else {
    //                   changeToBikeConnectFailedScreen(context);
    //                 }
    //               });
    //             }
    //             else {
    //               Future.delayed(const Duration(seconds: 3), (){
    //                 if (widget.isSuccess) {
    //                   changeToBikeConnectSuccessScreen(context);
    //                 }
    //                 else {
    //                   changeToBikeConnectFailedScreen(context);
    //                 }
    //               });
    //             }
    //           });
    //         }
    //         else {
    //           Future.delayed(const Duration(seconds: 3), (){
    //             if (widget.isSuccess) {
    //               changeToBikeConnectSuccessScreen(context);
    //             }
    //             else {
    //               changeToBikeConnectFailedScreen(context);
    //             }
    //           });
    //         }
    //       }
    //       else {
    //         Future.delayed(const Duration(seconds: 3), (){
    //           if (widget.isSuccess) {
    //             changeToBikeConnectSuccessScreen(context);
    //           }
    //           else {
    //             changeToBikeConnectFailedScreen(context);
    //           }
    //         });
    //       }
    //     }
    //     else {
    //       Future.delayed(const Duration(seconds: 3), (){
    //         if (widget.isSuccess) {
    //           changeToBikeConnectSuccessScreen(context);
    //         }
    //         else {
    //           changeToBikeConnectFailedScreen(context);
    //         }
    //       });
    //     }
    //   });
    // }
    // else {
    //   Future.delayed(const Duration(seconds: 3), (){
    //     if (widget.isSuccess) {
    //       changeToBikeConnectSuccessScreen(context);
    //     }
    //     else {
    //       changeToBikeConnectFailedScreen(context);
    //     }
    //   });
    // }

    Future.delayed(const Duration(seconds: 3), (){
      if (widget.isSuccess) {
        changeToBikeConnectSuccessScreen(context);
      }
      else {
        changeToBikeConnectFailedScreen(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
          body: Stack(
              children:[
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const EvieProgressIndicator(currentPageNumber: 1, totalSteps: 6,),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,4.h),
                        child: Text(
                          "Registering bike",
                          style: EvieTextStyles.h2,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 57.h),
                        child: Text(
                          "Please wait while EVIE app registering bike to your account. This may take a few moments.",
                          style: EvieTextStyles.body18,
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: EdgeInsets.only(top: 127.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Lottie.asset("assets/animations/registering-bike.json", repeat: true),
                  ),
                )
              ]
          )
      ),
    );
  }



}
