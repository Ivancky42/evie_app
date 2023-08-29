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

class RestoreBike extends StatefulWidget{
   const RestoreBike({Key?key}) : super(key:key);
   @override
   _RestoreBikeState createState() => _RestoreBikeState();
   }

   class _RestoreBikeState extends State<RestoreBike>{

   late BikeProvider _bikeProvider;
   late SettingProvider _settingProvider;

   @override
      Widget build(BuildContext context) {
      _bikeProvider = Provider.of<BikeProvider>(context);
      _settingProvider = Provider.of<SettingProvider>(context);

      return WillPopScope(
      onWillPop: () async {
        // _settingProvider.changeSheetElement(SheetList.resetBike2);
         return true;
      },
      child: Scaffold(
         appBar: PageAppbar(
      title: 'Reset Bike',
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
                            "Reset bike setting",
                           style: EvieTextStyles.h2,
                        ),
                     ),

                     Padding(
                         padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 12.h),
                        child:Text(
                           "Give your bike a delightful fresh start by resetting its setting to the default configuration. Use this option when you want to start a new or if you're experiencing any hiccups. Customise your bike's settings again for a happy riding experience! ",
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
                           "Reset Bike",
                           style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () {
                           //_settingProvider.changeSheetElement(SheetList.restoreCompleted);
                           _settingProvider.changeSheetElement(SheetList.restoreIncomplete);
                           ///showResetBike
                        },
                     ),
                  ),
               ),
            ]
         )
      ),
      );
   }
   }
