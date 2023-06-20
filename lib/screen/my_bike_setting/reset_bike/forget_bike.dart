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
import '../../../widgets/evie_button.dart';

class ForgetBike extends StatefulWidget{
  const ForgetBike({Key?key}) : super(key:key);
  @override
  _ForgetBikeState createState() => _ForgetBikeState();
}

class _ForgetBikeState extends State<ForgetBike>{

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        _settingProvider.changeSheetElement(SheetList.resetBike2);
        return false;
      },
      child: Scaffold(
              appBar: PageAppbar(
                title: 'Forget Bike',
                onPressed:(){
                  _settingProvider.changeSheetElement(SheetList.resetBike2);
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
                            "Farewell, [bike name]",
                            style: EvieTextStyles.h2,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 12.h),
                          child:Text(
                            "Ready to move on from this bike? No problem! By clicking this option, you're saying goodbye to this bike and all its connected settings. Have a great ride on your next adventure!",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
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
                            "Forget Bike",
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: () {
                            //_settingProvider.changeSheetElement(SheetList.forgetCompleted);
                            _settingProvider.changeSheetElement(SheetList.forgetIncomplete);
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
