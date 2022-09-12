import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:sizer/sizer.dart';
import '../api/provider/bike_provider.dart';

///Default user home page if login is true(display bicycle info)
class UserHomeGeneral extends StatefulWidget {
  const UserHomeGeneral({Key? key}) : super(key: key);
  @override
  _UserHomeGeneralState createState() => _UserHomeGeneralState();
}

class _UserHomeGeneralState extends State<UserHomeGeneral> {
  late BikeProvider _bikeProvider;
  final FocusNode _textFocus = FocusNode();
  final TextEditingController _bikeNameController = TextEditingController();

  bool isScroll = false;

  @override
  void initState() {
    _textFocus.addListener(() {
      onNameChange();
    });
    super.initState();
  }

  @override
  void dispose() {
    _textFocus.dispose();
    super.dispose();
  }

  ///Update bike name in firebase once !focus
  void onNameChange() {
    if (!_textFocus.hasFocus) {
      String text = _bikeNameController.text.trim();
      _bikeProvider.updateBikeName(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    LinkedHashMap bikeList = _bikeProvider.bikeList;

    ///Display "next", "back" button
    if (bikeList.length > 1) {
      setState(() {
        isScroll = true;
      });
    } else {
      setState(() {
        isScroll = false;
      });
    }

    return Scaffold(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: isScroll,
                      child: IconButton(
                        icon: const Image(
                          image:
                              AssetImage("assets/buttons/chg_to_left_bttn.png"),
                        ),
                        onPressed: () {
                          _bikeProvider.controlBikeList("back");
                        },
                      ),
                    ),
                    Image.asset(
                      'assets/evieBike.png',
                      height: 200,
                      width: 200,
                    ),
                    Visibility(
                      visible: isScroll,
                      child: IconButton(
                        icon: const Image(
                          image: AssetImage(
                              "assets/buttons/chg_to_right_bttn.png"),
                        ),
                        onPressed: () {
                          _bikeProvider.controlBikeList("next");
                        },
                      ),
                    ),
                  ],
                ),

                TextFormField(
                  enabled: true,
                  focusNode: _textFocus,
                  controller: _bikeNameController
                    ..text =
                        _bikeProvider.currentBikeModel?.bikeName ?? 'Empty',
                  style: const TextStyle(
                      fontFamily: 'Raleway-Bold', fontSize: 18.0),
                  decoration: const InputDecoration.collapsed(
                    hintText: "",
                    border: InputBorder.none,
                  ),
                ),

                const SizedBox(
                  height: 80.0,
                ),

                EvieButton_LightBlue(
                  height: 12.2.h,
                  width: double.infinity,
                  child: const Text(
                    "Connect To Bike",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
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

                ///Delete bike for development purpose
                EvieButton_LightBlue(
                  height: 12.2.h,
                  width: double.infinity,
                  child: const Text(
                    "Delete Bike_Development",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                  onPressed: () {
                    SmartDialog.show(
                        widget: EvieDoubleButtonDialog(
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
                                _bikeProvider
                                    .deleteBike(_bikeProvider.currentBikeModel!.deviceIMEI);
                                    SmartDialog.dismiss();
                              } catch (e) {
                                print(e.toString());
                              }
                            }));
                  },
                ),

                ///Sign out for development purpose
                /*
              EvieButton_LightBlue(
                width: double.infinity,
                child: const Text("Sign Out",
                  style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                ),
                onPressed: () {
                  _currentUser.signOut();
                },
              ),
               */

                const SizedBox(
                  height: 5.0,
                ),
              ]),
        ),
      ),
    ));
  }
}
