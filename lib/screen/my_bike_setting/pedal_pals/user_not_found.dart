import 'dart:collection';
import 'dart:io';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import 'package:share_plus/share_plus.dart';

import '../../../api/provider/setting_provider.dart';


class UserNotFound extends StatefulWidget{
  const UserNotFound({ Key? key }) : super(key: key);
  @override
  _UserNotFoundState createState() => _UserNotFoundState();
}

class _UserNotFoundState extends State<UserNotFound> {
  late SettingProvider _settingProvider;
  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },

      child: Scaffold(
          body: Stack(
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
                                padding: EdgeInsets.fromLTRB(24.w, 22.h, 16.w, 0),
                                child: Container(
                                  //color: Colors.red,
                                  width: 263.w,
                                  child: Text(
                                    "Share the app: Easily share the app with the rider you wish to bike with.",
                                    style: EvieTextStyles.body18,
                                  ),
                                ),
                              ),
                            );
                          }
                          else if (index == 1) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(24.w, 22.h, 16.w, 0),
                              child: Container(
                                width: 263.w,
                                child: Text(
                                  "Install and register: Kindly ask them to install the app and complete the registration process.",
                                  style: EvieTextStyles.body18,
                                ),
                              ),
                            );
                          }
                          else if (index == 2) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(24.w, 22.h, 16.w, 0),
                              child: Container(
                                width: 263.w,
                                child: Text(
                                  "Share once more: Once they are registered, share the app again to ensure seamless connection.",
                                  style: EvieTextStyles.body18,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
              ]),

                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom),
                //     child: EvieButton(
                //       width: double.infinity,
                //       height: 48.h,
                //       child: Text(
                //         "Done",
                //         style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 16.sp,
                //             fontWeight: FontWeight.w700),
                //       ),
                //       onPressed: () {
                //         _settingProvider.changeSheetElement(SheetList.pedalPalsList);
                //
                //       },
                //     ),
                //   ),
                // ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.screen_bottom),
                    child: EvieButton(
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
                          await Share.share('Hello there, you could download EVIE app from: \n $urlPreview');
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
                  ),
                ),
                
                //
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                //     child: EvieButton(
                //       width: double.infinity,
                //       height: 48.h,
                //       child: Text(
                //         "Done",
                //           style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                //       ),
                //       onPressed: () {
                //         _settingProvider.changeSheetElement(SheetList.shareBikeInvitation);
                //       },
                //     ),
                //   ),
                // ),





              ]),
    ));
  }
}