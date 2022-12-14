import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/screen/onboarding/turn_on_bluetooth.dart';
import 'package:evie_test/screen/onboarding/turn_on_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/location_provider.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_oval.dart';
import '../../../widgets/evie_single_button_dialog.dart';

class AddNewBike extends StatefulWidget {
  const AddNewBike({Key? key}) : super(key: key);

  @override
  _AddNewBikeState createState() => _AddNewBikeState();
}

class _AddNewBikeState extends State<AddNewBike> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;

  Color lockColour = const Color(0xff6A51CA);

  @override
  Widget build(BuildContext context) {

    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    final TextEditingController _bikeNameController = TextEditingController();

    final FocusNode _textFocus = FocusNode();

    Image addBikeImage = Image(
      image: const AssetImage("assets/buttons/plus.png"),
      height: 3.h,
      fit: BoxFit.fitWidth,
    );


    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await SmartDialog.show(
            widget:
            EvieDoubleButtonDialogCupertino(
                title: "Close this app?",
                content: "Are you sure you want to close this App?",
                leftContent: "No",
                rightContent: "Yes",
                onPressedLeft: (){SmartDialog.dismiss();},
                onPressedRight: (){SystemNavigator.pop();})) as bool?;
        return exitApp ?? false;
      },

      child: Scaffold(
        //Body should change when bottom navigation bar state change
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              _textFocus.unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                          height: 5.h,
                          child: FutureBuilder(
                              future:
                              _currentUserProvider.fetchCurrentUserModel,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return AnimatedTextKit(
                                      repeatForever: true,
                                      animatedTexts: [
                                        FadeAnimatedText(
                                            "Good Morning ${_currentUserProvider.currentUserModel!.name}",
                                            textAlign: TextAlign.center,
                                            duration: const Duration(
                                                milliseconds: 8000),
                                            fadeInEnd: 0.2,
                                            fadeOutBegin: 0.9),
                                        FadeAnimatedText(
                                            "${_currentUserProvider.randomQuote}",
                                            textAlign: TextAlign.center,
                                            duration: const Duration(
                                                milliseconds: 8000),
                                            textStyle: TextStyle(
                                                fontSize: 9.sp,
                                                fontFamily: "Avenir-Light",
                                                fontWeight: FontWeight.w200),
                                            fadeInEnd: 0.2,
                                            fadeOutBegin: 0.9),
                                      ]);
                                } else {
                                  return const Center(
                                    child: Text("Good Morning"),
                                  );
                                }
                              }),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 2.h,
                    ),

                    TextFormField(
                      textAlign: TextAlign.center,
                      enabled: false,
                      focusNode: _textFocus,
                      controller: _bikeNameController..text = 'Add New Bike',
                      style: const TextStyle(
                          fontFamily: 'Avenir-SemiBold', fontSize: 16.0),
                      decoration: const InputDecoration.collapsed(
                        hintText: "",
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),



                    SizedBox(
                      height: 4.h,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 20.h,
                          width: 90.w,
                          child: Image(
                            image: const AssetImage(
                                "assets/images/bike_HPStatus/bike_empty.png"),
                            height: 200.h,
                            colorBlendMode: BlendMode.overlay,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 30.0,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 10.w,
                          child: const Image(
                            image: AssetImage("assets/buttons/bike_security_not_available.png"),
                         //   height: 24.0,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Security Status",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            const Text(
                              "NOT AVAILABLE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            child: const Image(
                              image:
                              AssetImage("assets/buttons/carbon_seed.png"),
                              height: 24.0,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Carbon Foorprint",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "-g",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  EvieOvalGray(
                                      height: 3.h, width: 15.w, text: "D"),
                                ],
                              ),
                            ],
                          ),
                          const VerticalDivider(
                            thickness: 1,
                          ),
                          Container(
                            width: 10.w,
                            child: const Image(
                              image: AssetImage("assets/buttons/calories.png"),
                              height: 24.0,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mileage",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "-kcal",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  EvieOvalGray(
                                      height: 3.h, width: 15.w, text: "D"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 500,
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Connect To Bike",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () async {

                      },
                    ),

                    ///Delete bike for development purpose
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Delete Bike_Development",
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        SmartDialog.show(
                            widget: EvieDoubleButtonDialogCupertino(
                              //buttonNumber: "2",
                                title: "Delete bike",
                                content:
                                "Are you sure you want to delete this bike?",
                                leftContent: "Cancel",
                                rightContent: "Delete",

                                onPressedLeft: () {
                                  SmartDialog.dismiss();
                                },
                                onPressedRight: () {
                                  try {
                                    SmartDialog.dismiss();
                                    bool result = _bikeProvider.deleteBike(
                                        _bikeProvider
                                            .currentBikeModel!.deviceIMEI!
                                            .trim());
                                    if (result == true) {
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialogCupertino(
                                              title: "Success",
                                              content:
                                              "Successfully delete bike",
                                              rightContent: "OK",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    } else {
                                      SmartDialog.show(
                                          widget: EvieSingleButtonDialogCupertino(
                                              title: "Error",
                                              content:
                                              "Error delete bike, try again",
                                              rightContent: "OK",
                                              onPressedRight: () {
                                                SmartDialog.dismiss();
                                              }));
                                    }
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                }));
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Share Bike",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        changeToShareBikeScreen(context);
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Checkout plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        // StripeApiCaller.redirectToCheckout("price_1Lp0yCBjvoM881zMsahs6rkP", customerId).then((sessionId) {
                        //   changeToCheckoutScreen(context, sessionId);
                        // });
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Change Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        //StripeApiCaller.changeSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l", "price_1Lp11KBjvoM881zM7rIdanjj", "si_MY7fGJWs01DGF5");
                      },
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Cancel Plan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        //StripeApiCaller.cancelSubscription("sub_1Lp1PjBjvoM881zMuyOFI50l");
                      },
                    ),
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "RFID card",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        changeToRFIDScreen(context);
                      },
                    ),
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Sign out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () async {
                        try {

                          _authProvider.signOut(context).then((result){
                            if(result == true){

                              // _authProvider.clear();

                              changeToWelcomeScreen(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text('Signed out'),
                                  duration: Duration(
                                      seconds: 2),),
                              );
                            }else{
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text('Error, Try Again'),
                                  duration: Duration(
                                      seconds: 4),),
                              );

                            }

                          });
                        }
                        catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                    ),

                    SizedBox(
                      height: 1.h,
                    ),
                  ]),
            ),
          ),
        ),

        floatingActionButton: SizedBox(
          height: 10.8.h,
          width: 10.8.h,
          child: FittedBox(
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: lockColour,
              onPressed: () {

                changeToUserBluetoothScreen(context);
              },

              //icon inside button
              child: addBikeImage,
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
