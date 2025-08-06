import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/navigator.dart';
import '../../../widgets/evie_appbar.dart';



class DisplaySetting extends StatefulWidget{
  const DisplaySetting({ super.key });
  @override
  _DisplaySettingState createState() => _DisplaySettingState();
}

class _DisplaySettingState extends State<DisplaySetting> {

  late SettingProvider _settingProvider;



  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    return Scaffold(
      appBar: PageAppbar(
        title: 'Display Setting',
        onPressed: () {
          back(context, DisplaySetting());
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
              showMeasurementUnit(_settingProvider, context);
            },
            child: SizedBox(
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
                        SizedBox(width: 6.w,),
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

          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Divider(
              thickness: 0.2.h,
              color: EvieColors.darkWhite,
              height: 0,
            ),
          ),

        ],
      ),);
  }

}