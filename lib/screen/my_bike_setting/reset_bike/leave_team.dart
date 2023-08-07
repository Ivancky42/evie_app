import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_button.dart';

class LeaveTeam extends StatefulWidget{
  const LeaveTeam({Key?key}) : super(key:key);
  @override
  _LeaveTeamState createState() => _LeaveTeamState();
}

class _LeaveTeamState extends State<LeaveTeam>{

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
              title: 'Leave Team',
              onPressed:(){
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
                        padding:EdgeInsets.fromLTRB(16.w, 32.5.h, 16.w, 2.h),
                        child: Text(
                          "Farewell, Team",
                          style: TextStyle(fontSize: 26.sp, color: EvieColors.mediumBlack, fontWeight: FontWeight.w500),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 12.h),
                        child:Text(
                          "Are you ready to say goodbye to this bike-sharing team? "
                              "This action will remove your access to this bike and its related settings.",
                          style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, height: 1.3),
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
                          "Leave Team",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          //showBikeEraseSheet(context);
                          //showLeaveSuccessfulSheet(context);
                          showLeaveUnsuccessfulSheet(context);
                        },
                      ),
                    ),
                  ),
                ]
            )
        )
    );
  }
}