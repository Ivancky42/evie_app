import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../api/colours.dart';
import '../../api/enumerated.dart';
import '../../api/navigator.dart';
import 'bike_setting/bike_setting.dart';

class BikeSettingNavigator extends StatefulWidget {
  final BikeSettingList content;
  final String? source;

  const BikeSettingNavigator(
      this.content,
      this.source,
      {Key? key}) : super(key: key);

  @override
  State<BikeSettingNavigator> createState() => _BikeSettingNavigatorState();
}

class _BikeSettingNavigatorState extends State<BikeSettingNavigator> {

  Widget currentContent = const BikeSetting("Home");

  void changeContent(Widget newContent) {
    setState(() {
      currentContent = newContent;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: currentContent,
    );


  }
}


