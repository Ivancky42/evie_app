import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/enumerate.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../api/dialog.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_button.dart';

class UnlinkBike extends StatefulWidget{
  const UnlinkBike({super.key});
  @override
  _UnlinkBikeState createState() => _UnlinkBikeState();
}

class _UnlinkBikeState extends State<UnlinkBike>{

  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);


    return WillPopScope(
      onWillPop: () async {
        //_settingProvider.changeSheetElement(SheetList.resetBike2);

        return true;
      },
      child: Scaffold(
              appBar: PageAppbar(
                title: 'Unlink Bike',
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
                          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 4.h),
                          child: Text(
                            _bikeProvider.currentBikeModel?.pedalPalsModel != null ?
                            "Farewell, ${_bikeProvider.currentBikeModel?.deviceName ?? ''} "
                                "and ${_bikeProvider.currentBikeModel?.pedalPalsModel?.name ?? ''}" :
                            "Farewell, ${_bikeProvider.currentBikeModel?.deviceName ?? ''}",
                            style: EvieTextStyles.h2.copyWith(height: 1.3),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 0.h),
                          child:Text(
                            "Ready to remove this bike from your device? No problem!\n",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, height: 1.3),
                          ),
                        ),
                        _bikeProvider.currentBikeModel?.pedalPalsModel != null ?
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w,0.h, 16.w, 0.h),
                          child:Text(
                            "Select this option to unlink your bike from your account. Don’t worry, your bike will remember its settings if you choose to return! Keep in mind, [team name] will be disbanded.\n",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, height: 1.3),
                          ),
                        ) :
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w,0.h, 16.w, 0.h),
                          child:Text(
                            "Select this option to unlink your bike from your account. Don’t worry, your bike will remember its settings if you choose to return!\n",
                            style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack, height: 1.3),
                          ),
                        ),
                      ],
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.target_reference_button_a),
                        child: EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            "Unlink Bike",
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),

                          onPressed: () {

                          showUnlinkBikeDialog (context, _settingProvider);

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
