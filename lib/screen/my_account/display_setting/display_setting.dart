import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/notification_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_divider.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_switch.dart';
import '../my_account_widget.dart';



class DisplaySetting extends StatefulWidget{
  const DisplaySetting({ Key? key }) : super(key: key);
  @override
  _DisplaySettingState createState() => _DisplaySettingState();
}

class _DisplaySettingState extends State<DisplaySetting> {

  late SettingProvider _settingProvider;



  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        changeToMyAccount(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Display Setting',
          onPressed: () {
            changeToMyAccount(context);
          },
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h,),

            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){

                showMeasurementUnit(_settingProvider);
              },
              child: Container(
                height: 54.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Measurements",
                        style: EvieTextStyles.body18,
                      ),
                      Row(
                        children: [
                          Text(
                            splitCapitalString(capitalizeFirstCharacter(_settingProvider.currentMeasurementSetting.toString().split('.').last)),
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayish),
                          ),
                          SvgPicture.asset(
                            "assets/buttons/next.svg",
                            height: 24.h,
                            width: 24.w,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

           const EvieDivider(),

          ],
        ),),
    );
  }

}