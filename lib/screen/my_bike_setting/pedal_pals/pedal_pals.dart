import 'dart:collection';
import 'package:evie_bike/api/provider/auth_provider.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_bike/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_appbar.dart';


class PedalPals extends StatefulWidget{
  const PedalPals({ Key? key }) : super(key: key);
  @override
  _PedalPalsState createState() => _PedalPalsState();
}

class _PedalPalsState extends State<PedalPals> {


  LinkedHashMap bikeUserList = LinkedHashMap<String, BikeUserModel>();

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);


     return WillPopScope(
      onWillPop: () async {
        _settingProvider.changeSheetElement(SheetList.bikeSetting);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'PedalPals',
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

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,4.h),
                  child: Text(
                    "Share your bike with friends",
                    style: EvieTextStyles.h2,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                  child: Text(
                  "Create a team and invite up to 4 riders to share your EVIE bike. "
                      "PedalPals get access to unlocking, anti-theft features, notifications, and trip history.",
                    style: EvieTextStyles.body18,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,22.h),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/share_bike.svg",
                      height: 287.89.h,
                      width: 262.07.w,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,0.h),
                    child: Text(
                  "No rider is currently sharing your bike.",
                    style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                  ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                child: EvieButton(
                  width: double.infinity,
                  height: 48.h,
                  child: Text(
                    "Create Team",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                  ),
                  onPressed: () {

                    _settingProvider.changeSheetElement(SheetList.pedalPalsList);
                  },
                ),
              ),
            ),

          ],
        ),),
    );
  }

}