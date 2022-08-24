import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../widgets/evie_button.dart';
import '../widgets/evie_double_button_dialog.dart';
import 'package:sizer/sizer.dart';

import '../widgets/evie_slider.dart';
import '../widgets/evie_switch.dart';
import '../widgets/evie_textform.dart';

class UserHomeSetting extends StatefulWidget {
  const UserHomeSetting({Key? key}) : super(key: key);

  @override
  _UserHomeSettingState createState() => _UserHomeSettingState();
}

enum PlayBuzzerSound { onBike, onBikeNot }

class _UserHomeSettingState extends State<UserHomeSetting> {
  double _currentSliderValue = 2;

  bool _switchValue = true;
  bool _switchValue2 = false;
  Color thumbColor = Color(0xff00B6F1);
  Color thumbColor2 = Color(0xff899A9F);
  PlayBuzzerSound? _playBuzzerSound = PlayBuzzerSound.onBike;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        /*
        appBar: AppBar(
          title: const Text(
            "Setting",
            style: TextStyle(fontSize: 24.0,fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
           */

        body: Sizer(builder: (context, orientation, deviceType) {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    EvieSwitch(
                      text:"GPS Tracking",
                      value: _switchValue,
                      thumbColor: thumbColor,
                      onChanged: (value) {
                        setState(() {
                          _switchValue = value!;
                          if (value == true) {
                            thumbColor = Color(0xff00B6F1);
                          } else if (value == false) {
                            thumbColor = Color(0xff899A9F);
                          }
                        });
                      },
                    ),

                const SizedBox(
                  height: 10.0,
                ),

                    EvieSwitch(
                      text:"Fall Detection",
                      value: _switchValue2,
                      thumbColor: thumbColor2,
                      onChanged: (value) {
                        setState(() {
                          _switchValue2 = value!;
                          if (value == true) {
                            thumbColor2 = Color(0xff00B6F1);
                          } else if (value == false) {
                            thumbColor2 = Color(0xff899A9F);
                          }
                        });
                      },
                    ),
                const SizedBox(
                  height: 25.0,
                ),
                Row(children: [
                  const Text(
                    "Buzzer Min Interval  ",
                    style: TextStyle(
                      fontSize: 13.0,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${_currentSliderValue.round()} min",
                      style: const TextStyle(color: Color(0xff00B6F1)),
                    ),
                  )
                ]),

                    EvieSlider(
                      value: _currentSliderValue,
                      max: 10,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _currentSliderValue = value!;
                        });
                      },
                    ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  "Play Buzzer Sound",
                  style: TextStyle(
                    fontSize: 13.0,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          Row(children: [
                            Radio<PlayBuzzerSound>(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Color(0xff00B6F1)),
                              value: PlayBuzzerSound.onBike,
                              groupValue: _playBuzzerSound,
                              onChanged: (PlayBuzzerSound? value) {
                                setState(() {
                                  _playBuzzerSound = value;
                                });
                              },
                            ),
                            const Text(
                              'On Bike',
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ]),
                          Row(children: [
                            Radio<PlayBuzzerSound>(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Color(0xff00B6F1)),
                              value: PlayBuzzerSound.onBikeNot,
                              groupValue: _playBuzzerSound,
                              onChanged: (PlayBuzzerSound? value) {
                                setState(() {
                                  _playBuzzerSound = value;
                                });
                              },
                            ),
                            const Text(
                              'Other',
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ]),
                        ]),
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                EvieButton_White(
                  width: double.infinity,
                  height: 60,
                  child: const Text(
                    "Run Diagnostics",
                    style: TextStyle(
                      color: Color(0xff404E53),
                      fontSize: 13.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.show(
                        widget: EvieDoubleButtonDialog(
                            //buttonNumber: "2",
                            title: "Connect",
                            content: "In progress",
                            leftContent: "Cancel",
                            rightContent: "Ok",
                            image: Image.asset(
                              "assets/evieBike.png",
                              width: 36,
                              height: 36,
                            ),
                            onPressedLeft: () {
                              SmartDialog.dismiss();
                            },
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                EvieButton_White(
                  width: double.infinity,
                  height: 60,
                  child: const Text(
                    "OTA Update",
                    style: TextStyle(
                      color: Color(0xff404E53),
                      fontSize: 13.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.show(
                        widget: EvieDoubleButtonDialog(
                            //buttonNumber: "2",
                            title: "Connect",
                            content: "In progress",
                            leftContent: "Cancel",
                            rightContent: "Ok",
                            image: Image.asset(
                              "assets/evieBike.png",
                              width: 36,
                              height: 36,
                            ),
                            onPressedLeft: () {
                              SmartDialog.dismiss();
                            },
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  },
                ),
                const SizedBox(
                  height: 40.0,
                ),
                EvieButton_LightBlue(
                  width: double.infinity,
                  height: 11.h,
                  child: const Text(
                    "Factory Reset",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.show(
                        widget: EvieDoubleButtonDialog(
                            //buttonNumber: "2",
                            title: "Connect",
                            content: "In progress",
                            leftContent: "Cancel",
                            rightContent: "Ok",
                            image: Image.asset(
                              "assets/evieBike.png",
                              width: 36,
                              height: 36,
                            ),
                            onPressedLeft: () {
                              SmartDialog.dismiss();
                            },
                            onPressedRight: () {
                              SmartDialog.dismiss();
                            }));
                  },
                ),
              ])));
    }));
  }
}
