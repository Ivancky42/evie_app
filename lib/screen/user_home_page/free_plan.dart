import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../api/provider/location_provider.dart';
import '../../bluetooth/modelResult.dart';
import '../../widgets/evie_double_button_dialog.dart';
import '../../widgets/evie_oval.dart';
import '../../widgets/evie_single_button_dialog.dart';

class FreePlan extends StatefulWidget {
  const FreePlan({Key? key}) : super(key: key);

  @override
  _FreePlanState createState() => _FreePlanState();
}

class _FreePlanState extends State<FreePlan> {
  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;
  late BluetoothProvider _bluetoothProvider;

  Color lockColour = const Color(0xff6A51CA);

  ///When get data from _bluetoothProvider.cableLockState is not equal to unknown
  ///Need either lock/unlock
  bool? isDeviceConnected;

  final CarouselController _pageController = CarouselController();

  late List<String> imgList = [
    'assets/images/bike_HPStatus/bike_normal.png',
    'assets/images/bike_HPStatus/bike_normal.png',
  ];

  String carbonFootprint = "D";
  String mileage = "D";

  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;

  CableLockResult? cableLockState;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
    cableLockState = _bluetoothProvider.cableLockState;

    final TextEditingController _bikeNameController = TextEditingController();

    final FocusNode _textFocus = FocusNode();


    ///Handle all data if bool isDeviceConnected is true
    if(connectionState == DeviceConnectionState.connected && cableLockState?.lockState != LockState.unknown){
      setState(() {
        isDeviceConnected = true;
      });
    }else{
      setState(() {
        isDeviceConnected = false;
      });
    }


    Image connectImage = Image(
      image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
      height: 2.5.h,
      fit: BoxFit.fitWidth,
    );

    if(connectionState?.name == "connected"){
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/lock_lock.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });

    }else if(connectionState?.name == "connecting"){
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/loading.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    }else if(connectionState?.name == "disconnected"){
      setState(() {
         connectImage = Image(
          image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
      });
    }


    Image lockImage = Image(
      image: const AssetImage("assets/buttons/lock_lock.png"),
      height: 2.5.h,
      fit: BoxFit.fitWidth,
    );



    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await SmartDialog.show(
            widget: EvieDoubleButtonDialogCupertino(
                title: "Close this app?",
                content: "Are you sure you want to close this App?",
                leftContent: "No",
                rightContent: "Yes",
                onPressedLeft: () {
                  SmartDialog.dismiss();
                },
                onPressedRight: () {
                  SystemNavigator.pop();
                })) as bool?;
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
                      enabled: true,
                      focusNode: _textFocus,
                      controller: _bikeNameController
                        ..text = _bikeProvider.currentBikeModel?.deviceName
                                ?.trim() ??
                            'Empty',
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

                    /*
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image:
                          const AssetImage("assets/icons/battery_full.png"),
                          height: 1.h,
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        const Text("100%"),
                        SizedBox(
                          width: 1.w,
                        ),
                        const Text("· Est 50km")
                      ],
                    ),

                     */

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Image(
                          image: AssetImage("assets/icons/unlink.png"),
                          //height: 1.h,
                        ),
                        SizedBox(
                          width: 1.w,
                        ),
                        const Text(
                          "Bike Is Not Connected",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 4.h,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: [
                            Positioned(
                              left: 2.w,
                              top: 5.h,
                              child: Visibility(
                                visible: _bikeProvider.userBikeList.length > 1
                                    ? true
                                    : false,
                                child: IconButton(
                                  icon: const Image(
                                    image:
                                        AssetImage("assets/buttons/back.png"),
                                  ),
                                  onPressed: () {
                                    _bikeProvider.controlBikeList("back");
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                              width: 90.w,
                              child: CarouselSlider(
                                  carouselController: _pageController,
                                  items: imgList
                                      .map((item) => Container(
                                            child: Center(
                                              child: Image.asset(
                                                item,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 200.h,
                                                opacity:
                                                    const AlwaysStoppedAnimation(
                                                        .5),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  options: CarouselOptions(
                                    onPageChanged: (index, reason) {
                                      var _currentCarouIndex = 0;

                                      if (index >= _currentCarouIndex) {
                                        _bikeProvider.controlBikeList("next");
                                      } else {
                                        _bikeProvider.controlBikeList("back");
                                      }
                                    },
                                    enableInfiniteScroll: true,
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                  )),
                            ),
                            Positioned(
                              right: 2.w,
                              top: 5.h,
                              child: Visibility(
                                visible: _bikeProvider.userBikeList.length > 1
                                    ? true
                                    : false,
                                child: IconButton(
                                  icon: const Image(
                                    image:
                                        AssetImage("assets/buttons/next.png"),
                                  ),
                                  onPressed: () {
                                    _bikeProvider.controlBikeList("next");
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 4.h,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 10.w,
                          child: const Image(
                            image: AssetImage(
                                "assets/buttons/bike_security_not_available.png"),
                            //height: 5.h,
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
                              "BIKE NOT CONNECTED",
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
                                "Carbon Footprint",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12),
                              ),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "-g",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (carbonFootprint == "D") {
                                        setState(() {
                                          carbonFootprint = "M";
                                        });
                                      } else if (carbonFootprint == "M") {
                                        setState(() {
                                          carbonFootprint = "D";
                                        });
                                      }
                                    },
                                    child: EvieOvalGray(
                                        height: 3.h,
                                        width: 15.w,
                                        text: carbonFootprint),
                                  )
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
                              image: AssetImage("assets/buttons/mileage.png"),
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
                                  GestureDetector(
                                    onTap: () {
                                      if (mileage == "D") {
                                        setState(() {
                                          mileage = "M";
                                        });
                                      } else if (mileage == "M") {
                                        setState(() {
                                          mileage = "D";
                                        });
                                      }
                                    },
                                    child: EvieOvalGray(
                                        height: 3.h,
                                        width: 15.w,
                                        text: mileage),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                      height: 50.h,
                    ),


                    Text(
                      "Connection status : " + (cableLockState?.lockState.toString() ?? "none"),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(
                      height: 1.h,
                    ),
                  ]),
            ),
          ),
        ),


        /// change to isDeviceConnected
        floatingActionButton: cableLockState?.lockState != null ?  SizedBox(
          height: 8.8.h,
          width: 8.8.h,
          child: FittedBox(
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: lockColour,
              onPressed: () {

                ///Check is connected

                SmartDialog.showLoading(msg: "Unlocking");
                StreamSubscription? subscription;
                subscription = _bluetoothProvider.cableUnlock().listen((unlockResult) {
                  SmartDialog.dismiss(status: SmartStatus.loading);
                  subscription?.cancel();
                  if (unlockResult.result == CommandResult.success) {
                    print("unlock success");
                  }
                  else {
                    print("unlock not success");
                  }
                }, onError: (error) {
                  SmartDialog.dismiss(status: SmartStatus.loading);
                  subscription?.cancel();
                  print(error);
                });
              },
              //icon inside button
              child: lockImage,
            ),
          ),
        ): SizedBox(
          height: 8.8.h,
          width: 8.8.h,
          child: FittedBox(
            child:
            FloatingActionButton(
              elevation: 0,
              backgroundColor: lockColour,
              onPressed: () {

                ///Check bluetooth status

                if (connectionState == null || connectionState?.name == "disconnected") {
                  _bluetoothProvider.connectDevice();
                }else{
                 print("not connect");
                }
              },
              //icon inside button
              child: connectImage,
            )
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
