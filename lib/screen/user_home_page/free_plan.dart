import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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

  String carbonFootprint = "D";
  String mileage = "D";

  DeviceConnectionState? connectionState;
  ConnectionStateUpdate? connectionStateUpdate;
  CableLockResult? cableLockState;

  Image connectImage = Image(
    image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
    height: 2.5.h,
    fit: BoxFit.fitWidth,
  );

  Image lockImage = Image(
    image: const AssetImage("assets/buttons/lock_lock.png"),
    height: 2.5.h,
    fit: BoxFit.fitWidth,
  );

  List<String> imgList = [
    'assets/images/bike_HPStatus/bike_normal.png',
  ];

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    connectionState = _bluetoothProvider.connectionStateUpdate?.connectionState;
    connectionStateUpdate = _bluetoothProvider.connectionStateUpdate;
    cableLockState = _bluetoothProvider.cableLockState;

    final TextEditingController _bikeNameController = TextEditingController();

    final FocusNode _textFocus = FocusNode();

    ///Handle all data if bool isDeviceConnected is true
    if (connectionState == DeviceConnectionState.connected &&
        cableLockState?.lockState == LockState.lock || cableLockState?.lockState == LockState.unlock) {
      setState(() {
        isDeviceConnected = true;
      });
    } else {
      setState(() {
        isDeviceConnected = false;
      });
    }

    Future.delayed(Duration.zero,(){
    if(_bluetoothProvider.connectionStateUpdate?.failure != null){
      _bluetoothProvider.disconnectDevice(connectionStateUpdate!.deviceId);
      SmartDialog.show(
          keepSingle: true,
          widget: EvieSingleButtonDialogCupertino(
              title: "Cannot connect bike",
              content: "Move your device near the bike and try again",
              rightContent: "OK",
              onPressedRight: (){SmartDialog.dismiss();}));
    }
    });

    setConnectImage();
    setLockImage();
    setBikeImage();

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

                    if (isDeviceConnected == true) ...{
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getBatteryImage(
                              _bikeProvider.currentBikeModel!.batteryPercent!),
                          SizedBox(
                            width: 1.w,
                          ),
                          Text(_bikeProvider.currentBikeModel!.batteryPercent!
                              .toString()),
                          SizedBox(
                            width: 1.w,
                          ),
                          const Text("· Est 0km")
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
                                      _bluetoothProvider.disconnectDevice(
                                          connectionStateUpdate!.deviceId);
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
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    options: CarouselOptions(
                                      onPageChanged: (index, reason) {
                                        _bluetoothProvider.disconnectDevice(
                                            connectionStateUpdate!.deviceId);
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
                                      _bluetoothProvider.disconnectDevice(
                                          connectionStateUpdate!.deviceId);
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
                            child: getSecurityImageWidget(


                                cableLockState!.lockState,
                                _bikeProvider
                                    .currentBikeModel!.location!.status),
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
                              getSecurityTextWidget(
                                  cableLockState!.lockState,
                                  _bikeProvider
                                      .currentBikeModel!.location!.status),
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
                                image: AssetImage(
                                    "assets/buttons/carbon_seed.png"),
                                height: 24.0,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Carbon Footprint",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "12g",
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
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "12km",
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
                    } else ...{
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
                      if (connectionState?.name == "connecting") ...{
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(
                              image:
                              AssetImage("assets/icons/loading_small.png"),
                              //height: 1.h,
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            const Text(
                              "Connecting Bike...",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      } else ...{
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
                      },
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
                                image: AssetImage(
                                    "assets/buttons/carbon_seed.png"),
                                height: 24.0,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Carbon Footprint",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
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
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
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
                    },

                    SizedBox(
                      height: 50.h,
                    ),

                    Text(
                      "Connection status : " +
                          (cableLockState?.lockState.toString() ?? "none"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),

                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Unlock bike",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        SmartDialog.showLoading(msg: "Unlocking");
                        StreamSubscription? subscription;
                        subscription = _bluetoothProvider.cableUnlock().listen(
                            (unlockResult) {
                          SmartDialog.dismiss(status: SmartStatus.loading);
                          subscription?.cancel();
                          if (unlockResult.result == CommandResult.success) {
                            print("unlock success");
                          } else {
                            print("unlock not success");
                          }
                        }, onError: (error) {
                          SmartDialog.dismiss(status: SmartStatus.loading);
                          subscription?.cancel();
                          print(error);
                        });
                      },
                    ),

                    ///Delete bike for development purpose
                    EvieButton(
                      height: 12.2.h,
                      width: double.infinity,
                      child: const Text(
                        "Delete Bike",
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
                                image: Image.asset(
                                  "assets/evieBike.png",
                                  width: 36,
                                  height: 36,
                                ),
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
                                          widget:
                                              EvieSingleButtonDialogCupertino(
                                                  title: "Success",
                                                  content:
                                                      "Successfully delete bike",
                                                  rightContent: "OK",
                                                  onPressedRight: () {
                                                    SmartDialog.dismiss();
                                                  }));
                                    } else {
                                      SmartDialog.show(
                                          widget:
                                              EvieSingleButtonDialogCupertino(
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
                          _authProvider.signOut(context).then((result) {
                            if (result == true) {
                              // _authProvider.clear();

                              changeToWelcomeScreen(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Signed out'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error, Try Again'),
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          });
                        } catch (e) {
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

        /// change to isDeviceConnected
        floatingActionButton: cableLockState?.lockState != null
            ? SizedBox(
                height: 8.8.h,
                width: 8.8.h,
                child: FittedBox(
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: cableLockState?.lockState == LockState.lock
                        ? lockColour
                        : const Color(0xffC1B7E8),
                    onPressed: cableLockState?.lockState == LockState.lock
                        ? () {
                            ///Check is connected

                            SmartDialog.showLoading(msg: "Unlocking");
                            StreamSubscription? subscription;
                            subscription = _bluetoothProvider
                                .cableUnlock()
                                .listen((unlockResult) {
                              SmartDialog.dismiss(status: SmartStatus.loading);
                              subscription?.cancel();
                              if (unlockResult.result ==
                                  CommandResult.success) {
                                subscription?.cancel();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Bike is unlocked. To lock bike......'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                SmartDialog.dismiss(
                                    status: SmartStatus.loading);
                                subscription?.cancel();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    width:90.w,
                                    behavior: SnackBarBehavior.floating,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))),
                                    content: Container(
                                      height:9.h,
                                      child: Column(
                                        children: [
                                          const Align(
                                            alignment: Alignment.topLeft,
                                            child:   Text('Bike is unlocked. To lock bike......'),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              child:  const Text('LEARN MORE', style: TextStyle(color: Color(0xff836ED3)),),
                                              onPressed: (){
                                              },
                                            ),
                                          ),

                                        ],

                                      ),
                                    ),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            }, onError: (error) {
                              SmartDialog.dismiss(status: SmartStatus.loading);
                              subscription?.cancel();
                              SmartDialog.show(
                                  widget: EvieSingleButtonDialogCupertino(
                                      title: "Error",
                                      content:
                                          "Cannot unlock bike, please place the phone near the bike and try again.",
                                      rightContent: "OK",
                                      onPressedRight: () {
                                        SmartDialog.dismiss();
                                      }));
                            });
                          }
                        : null,
                    //icon inside button
                    child: lockImage,
                  ),
                ),
              )
            : SizedBox(
                height: 8.8.h,
                width: 8.8.h,
                child: FittedBox(
                    child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: lockColour,
                  onPressed: () {
                    ///Check bluetooth status

                    var bleStatus = _bluetoothProvider.bleStatus;
                    switch (bleStatus) {
                      case BleStatus.poweredOff:
                        SmartDialog.show(
                            keepSingle: true,
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Error",
                                content:
                                    "Bluetooth is off, please turn on your bluetooth",
                                rightContent: "OK",
                                onPressedRight: () {
                                  SmartDialog.dismiss();
                                }));
                        break;
                      case BleStatus.unknown:
                        // TODO: Handle this case.
                        break;
                      case BleStatus.unsupported:
                        SmartDialog.show(
                            keepSingle: true,
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Error",
                                content: "Bluetooth unsupported",
                                rightContent: "OK",
                                onPressedRight: () {
                                  SmartDialog.dismiss();
                                }));
                        break;
                      case BleStatus.unauthorized:
                        // TODO: Handle this case.
                        break;
                      case BleStatus.locationServicesDisabled:
                        SmartDialog.show(
                            keepSingle: true,
                            widget: EvieSingleButtonDialogCupertino(
                                title: "Error",
                                content: "Location service disabled",
                                rightContent: "OK",
                                onPressedRight: () {
                                  SmartDialog.dismiss();
                                }));
                        break;
                      case BleStatus.ready:
                        if (connectionState == null ||
                            connectionState ==
                                DeviceConnectionState.disconnected) {


                            _bluetoothProvider.connectDevice();



                            // if(connectionStateUpdate != null){
                            //   if(connectionStateUpdate?.failure.toString() != null){
                            //     SmartDialog.show(
                            //         keepSingle: true,
                            //         widget: EvieSingleButtonDialogCupertino(
                            //             title: "Error",
                            //             content: "Cannot connect bike, please place the phone near the bike and try again.",
                            //             rightContent: "OK",
                            //             onPressedRight: (){SmartDialog.dismiss();})
                            //     );
                            //   }
                            // }

                        } else {

                        }
                        break;
                      default:
                        break;
                    }
                  },
                  //icon inside button
                  child: connectImage,
                )),
              ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget getBatteryImage(int batteryPercent) {
    if (batteryPercent > 50 && batteryPercent <= 100) {
      return Image(
        image: const AssetImage("assets/icons/battery_full.png"),
        height: 1.h,
      );
    } else if (batteryPercent > 10 && batteryPercent <= 50) {
      return Image(
        image: const AssetImage("assets/icons/battery_half.png"),
        height: 1.h,
      );
    } else if (batteryPercent > 0 && batteryPercent <= 10) {
      return Image(
        image: const AssetImage("assets/icons/battery_low.png"),
        height: 1.h,
      );
    } else if (batteryPercent == 0) {
      return Image(
        image: const AssetImage("assets/icons/battery_empty.png"),
        height: 1.h,
      );
    } else {
      return Image(
        image: const AssetImage("assets/icons/battery_empty.png"),
        height: 1.h,
      );
    }
  }

  Widget getSecurityTextWidget(LockState isLocked, String status) {
    switch (isLocked) {
      case LockState.lock:
        if (status == "safe") {
          return const Text(
            "LOCKED AND SECURE",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        } else if (status == "warning") {
          return const Text(
            "ATTENTION NEEDED",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        } else if (status == "danger") {
          return const Text(
            "UNDER THREAT",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        }
        break;
      case LockState.unlock:
        if (status == "safe") {
          return const Text(
            "UNLOCKED",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        } else if (status == "warning") {
          return const Text(
            "ATTENTION NEEDED",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        } else if (status == "danger") {
          return const Text(
            "UNDER THREAT",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          );
        }
        break;
      case LockState.unknown:
        // TODO: Handle this case.
        break;
    }

    return const Text(
      "LOCKED AND SECURE",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget getSecurityImageWidget(LockState isLocked, String status) {
    switch (isLocked) {
      case LockState.lock:
        if (status == "safe") {
          return const Image(
            image:
                AssetImage("assets/buttons/bike_security_lock_and_secure.png"),
            //height: 5.h,
          );
        } else if (status == "warning") {
          return const Image(
            image: AssetImage("assets/buttons/bike_security_warning.png"),
            //height: 5.h,
          );
        } else if (status == "danger") {
          return const Image(
            image: AssetImage("assets/buttons/bike_security_danger.png"),
            //height: 5.h,
          );
        }
        break;
      case LockState.unlock:
        if (status == "safe") {
          return const Image(
            image: AssetImage("assets/buttons/bike_security_unlock.png"),
            //height: 5.h,
          );
        } else if (status == "warning") {
          return const Image(
            image: AssetImage("assets/buttons/bike_security_warning.png"),
            //height: 5.h,
          );
        } else if (status == "danger") {
          return const Image(
            image: AssetImage("assets/buttons/bike_security_danger.png"),
            //height: 5.h,
          );
        }
        break;
      case LockState.unknown:
        // TODO: Handle this case.
        break;
    }
    return const Image(
      image: AssetImage("assets/buttons/bike_security_lock_and_secure.png"),
      //height: 5.h,
    );
  }

  void setConnectImage() {
    if (connectionState?.name == "connected") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/lock_lock.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (connectionState?.name == "connecting") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/loading.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (connectionState?.name == "disconnected") {
      setState(() {
        connectImage = Image(
          image: const AssetImage("assets/buttons/bluetooth_not_connected.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
      });
    }
  }

  void setLockImage() {
    if (cableLockState?.lockState == LockState.lock) {
      setState(() {
        lockImage = Image(
          image: const AssetImage("assets/buttons/lock_lock.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    } else if (cableLockState?.lockState == LockState.unlock) {
      setState(() {
        lockImage = Image(
          image: const AssetImage("assets/buttons/lock_unlock.png"),
          height: 2.5.h,
          fit: BoxFit.fitWidth,
        );
        lockColour = const Color(0xff6A51CA);
      });
    }
  }

  void setBikeImage() {
    if (isDeviceConnected == true) {
      switch (_bikeProvider.currentBikeModel!.location!.status) {
        case "safe":
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_safe.png',
            ];
          });
          break;
        case "warning":
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_warning.png',
            ];
          });
          break;
        case "danger":
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_danger.png',
            ];
          });
          break;
        default:
          setState(() {
            imgList = [
              'assets/images/bike_HPStatus/bike_normal.png',
            ];
          });
      }
    } else {
      setState(() {
        imgList = [
          'assets/images/bike_HPStatus/bike_normal.png',
        ];
      });
    }
  }
}
