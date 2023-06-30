import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import 'package:share_plus/share_plus.dart';

import '../../../api/provider/setting_provider.dart';


class UserNotFound extends StatefulWidget{
  final String email;
  const UserNotFound(this.email,{ Key? key }) : super(key: key);
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
        return false;
      },

      child: Scaffold(
          body: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w,76.h,16.w,4.h),
                      child: Text(
                        "User Not Found",
                        style: EvieTextStyles.h2,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                      child: Container(
                        child: Text(
                          "User not found in EVIE database.",
                          style: EvieTextStyles.body18,
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(28.w,98.h,28.w,127.84.h),
                        child: SvgPicture.asset(
                          "assets/images/send_email.svg",
                        ),
                      ),
                    ),


              ]),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.buttonWord_ButtonBottom = 108.h),
                    child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                          "Share App",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                      ),
                      onPressed: () async {

                        var urlPreview = Platform.isIOS ?
                        'https://apps.apple.com/my/app/pok%C3%A9mon-magikarp-jump/id1162679453' :
                        'https://play.google.com/store/apps/details?id=jp.pokemon.koiking&hl=en&gl=US';

                        await Share.share('Hello there, you could download EVIE app from: \n $urlPreview');

                        // List<XFile> xfiles = [XFile('assets/images/evie_bike_shadow_half.png')];
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

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
                    child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Done",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                      ),
                      onPressed: () {
                        _settingProvider.changeSheetElement(SheetList.shareBikeInvitation);
                      },
                    ),
                  ),
                ),

              ]),
    ));
  }
}