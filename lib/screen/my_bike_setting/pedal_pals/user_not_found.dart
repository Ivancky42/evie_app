import 'dart:io';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import 'package:share_plus/share_plus.dart';

import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';


class UserNotFound extends StatefulWidget{
  const UserNotFound({ super.key });
  @override
  _UserNotFoundState createState() => _UserNotFoundState();
}

class _UserNotFoundState extends State<UserNotFound> {
  late SettingProvider _settingProvider;
  late BikeProvider _bikeProvider;


  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },

      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w,72.h,16.w,4.h),
                    child: Text(
                      "User Not Found",
                      style: EvieTextStyles.h2,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w,34.h),
                    child: Text(
                      "Sorry, we can’t find the user you’re looking for. Have both you and your PedalPal installed and register yourselves on the EVIE app?",
                      style: EvieTextStyles.body18,
                    ),
                  ),

                  Timeline.tileBuilder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    theme: TimelineThemeData(
                      color: EvieColors.mediumLightBlack,
                      nodePosition: 0.08,
                      indicatorPosition: 0.5,
                    ),
                    shrinkWrap: true,
                    builder: TimelineTileBuilder(
                      itemCount: 3,
                      contentsAlign: ContentsAlign.basic,
                      startConnectorBuilder: (context, index) {
                        if(index == 0){
                          return const TransparentConnector();
                        }
                        else{
                          return const DashedLineConnector(thickness: 1.2, color: EvieColors.lightGrayish);
                        }
                      },
                      endConnectorBuilder: (context, index) {
                        if(index == 2){
                          return const TransparentConnector();
                        }else {
                          return const DashedLineConnector(thickness: 1.2, color: EvieColors.lightGrayish);
                        }
                      },
                      indicatorBuilder: (context, index) {
                        return SvgPicture.asset(
                          "assets/images/share_0${index + 1}.svg",
                        );
                      },
                      contentsBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            //color: Colors.yellow,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(24.w, 22.h, 32.w, 0),
                              child: Container(
                                //color: Colors.red,
                                //width: 263.w,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Share the app: ",
                                        style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Avenir'),
                                      ),
                                      TextSpan(
                                        text: "Easily share the app with the rider you wish to bike with.",
                                        style: EvieTextStyles.body18.copyWith(color: Colors.black, fontFamily: 'Avenir'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        else if (index == 1) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 22.h, 32.w, 0),
                            child: SizedBox(
                              width: 263.w,
                              child:
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Install and register: ",
                                      style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Avenir'),
                                    ),
                                    TextSpan(
                                      text: "Kindly ask them to install the app and complete the registration process.",
                                      style: EvieTextStyles.body18.copyWith(color: Colors.black, fontFamily: 'Avenir'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        else if (index == 2) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 22.h, 32.w, 0),
                            child: SizedBox(
                              width: 263.w,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Share once more: ",
                                      style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Avenir'),
                                    ),
                                    TextSpan(
                                      text: "Once they are registered, share the app again to ensure seamless \nconnection.",
                                      style: EvieTextStyles.body18.copyWith(color: Colors.black, fontFamily: 'Avenir'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ]),

            Padding(
                padding: EdgeInsets.fromLTRB(16.w,0,16.w, EvieLength.target_reference_button_a),
                child: Column(
                  children: [
                    EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                          "Share App",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                      ),
                      onPressed: () async {

                        var urlPreview = Platform.isIOS ?
                        'https://apps.apple.com/us/app/evie-bikes/id1671127862' :
                        'https://play.google.com/store/apps/details?id=com.evie.app';

                        try{
                          await Share.share("Ready for cycling fun? 🚴‍♂️ Join my team on EVIE app. Download the app and let the adventures begin! After registering, drop me a notification—I'll shoot you an invite to join the team! 🚀 \n $urlPreview");
                          //print("Success");
                        }catch(e){
                          //print("Share fail");
                        }


                        // List<XFile> xfiles = [XFile('assets/images/evie_test_shadow_half.png')];
                        //
                        // await Share.shareXFiles(xfiles,text: 'Share some files');


                        // final urlImage = Uri.parse('https://cdn.shopify.com/s/files/1/0662/8510/9531/products/evie-bikes-s1-832210_1500x1500.webp?v=1680153934');
                        // final response = await http.get(urlImage);
                        // final bytes = response.bodyBytes;
                        //
                        // final temp = await getTemporaryDirectory();
                        // final path = '${temp.path}/image.jpg';
                        // File(path).writeAsBytes(bytes);

                      },
                    ),
                    SizedBox(height: 8.h,),
                    EvieButton_ReversedColor(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                          "Done",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)
                      ),
                      onPressed: () {
                        if(_bikeProvider.currentBikeModel?.pedalPalsModel == null || _bikeProvider.currentBikeModel?.pedalPalsModel?.name == ""){
                          _settingProvider.changeSheetElement(SheetList.pedalPals);
                        }else{
                          _settingProvider.changeSheetElement(SheetList.pedalPalsList, _bikeProvider.currentBikeModel?.deviceIMEI);
                        }
                      },
                    ),
                  ],
                )
            ),

          ]),
    );
  }
}