import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/setting.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_button.dart';

class ResetBike2 extends StatefulWidget{
  const ResetBike2({ Key? key }) : super(key: key);
  @override
  _ResetBike2State createState() => _ResetBike2State();
}

class _ResetBike2State extends State<ResetBike2> {

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    
    return WillPopScope(
        onWillPop: () async {
          _settingProvider.changeSheetElement(SheetList.bikeSetting);
          return false;
        },
        child: Scaffold(
          appBar: PageAppbar(
            title: 'Reset',
            onPressed: () {
              _settingProvider.changeSheetElement(SheetList.bikeSetting);
            },
          ),
          body: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SvgPicture.asset("assets/images/bike_erase.svg",
                    width: 279.49,
                    height: 157.64,
                    ),

                  ],
                ),
              ]
          ),
        )
    );
  }

}