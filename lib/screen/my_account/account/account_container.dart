import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/account/account_model.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting_model.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../api/enumerate.dart';
import '../../../api/function.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../bluetooth/modelResult.dart';

class AccountContainer extends StatefulWidget {
  final AccountModel accountModel;
  const AccountContainer({Key? key, required this.accountModel}) : super(key: key);

  @override
  State<AccountContainer> createState() => _AccountContainerState();
}

class _AccountContainerState extends State<AccountContainer> {

  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;
  late SettingProvider _settingProvider;
  late BluetoothProvider _bluetoothProvider;

  DeviceConnectResult? deviceConnectResult;
  String? label;
  String? pageNavigate;

  // @override
  // Future<void> initState() async {
  //  packageInfo = await PackageInfo.fromPlatform();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    label = widget.accountModel.label;
    _bikeProvider = Provider.of<BikeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    switch(label) {
      case "Personal Information":
        return Column(
          children: [

            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {

                changeToEditProfile(context);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      // case "My Garage":
      //   return Column(
      //     children: [
      //       GestureDetector(
      //         behavior: HitTestBehavior.translucent,
      //         onTap: () {
      //
      //   changeToMyGarageScreen(context);
      //         },
      //         child: Container(
      //           height: 44.h,
      //           child: Padding(
      //               padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Row(
      //                     children: [
      //                       Text(
      //                         label!,
      //                         style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
      //                       ),
      //                     ],
      //                   ),
      //                   SvgPicture.asset(
      //                     "assets/buttons/next.svg",
      //                   ),
      //                 ],
      //               )
      //           ),
      //         ),
      //       ),
      //       const EvieDivider(),
      //     ],
      //   );
      case "Push Notification":
        return Column(
          children: [
            Divider(
              thickness: 11.h,
              color: EvieColors.dividerWhite,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {

                changeToPushNotification(context);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Email Newsletter":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {

              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Display Setting":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeToDisplaySetting(context);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/next.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Help Center":
        return Column(
          children: [
            Divider(
              thickness: 11.h,
              color: EvieColors.dividerWhite,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                const url = 'https://support.eviebikes.com/en-US';
                final Uri _url = Uri.parse(url);
                launch(_url);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/external_link.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Privacy Policies":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                const url = 'https://eviebikes.com/policies/privacy-policy';
                final Uri _url = Uri.parse(url);
                launch(_url);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/external_link.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      case "Terms & Conditions":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                const url = 'https://eviebikes.com/policies/terms-of-service';
                final Uri _url = Uri.parse(url);
                launch(_url);
              },
              child: Container(
                height: 44.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              label!,
                              style: EvieTextStyles.body18.copyWith(color: EvieColors.lightBlack),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          "assets/buttons/external_link.svg",
                        ),
                      ],
                    )
                ),
              ),
            ),
            const EvieDivider(),

            Padding(
              padding: EdgeInsets.only(
                  left: 16.w, right: 16.w, top: 24.h, bottom: 10.h),
              child: Container(
                height: 45.h,
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                    "Logout",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                  ),
                  onPressed: () async {
                    SmartDialog.showLoading();
                    try {
                      await _authProvider.signOut(context).then((result) async {
                        if (result == true) {
                          await _bikeProvider.clear();
                          SmartDialog.dismiss();
                          // _authProvider.clear();
                          changeToWelcomeScreen(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Signed out'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          SmartDialog.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error, Try Again'),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      });
                    } catch (e) {
                      debugPrint(e.toString());
                      SmartDialog.dismiss();
                      showFailed();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side:  BorderSide(color: EvieColors.darkGrayish, width: 1.5.w)),
                    elevation: 0.0,
                    backgroundColor: EvieColors.transparent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 16.w, right: 16.w, top: 0.h, bottom: 6.h),
              child: Container(
                height: 45.h,
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                    "Revoke Account",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                  ),
                  onPressed: ()  {


                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side:  BorderSide(color: EvieColors.darkGrayish, width: 1.5.w)),
                    elevation: 0.0,
                    backgroundColor: EvieColors.transparent,

                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "${_settingProvider.packageInfo?.appName ?? "Evie Bike"} ${_settingProvider.packageInfo?.version ?? "v1.0.0"} (${_settingProvider.packageInfo?.buildNumber ?? "0"})",
                      style: EvieTextStyles.body12.copyWith(color:EvieColors.darkWhite),
                    ),
                    Text(
                      "Copyright 2023 by Hyperion Innovations",
                      style: EvieTextStyles.body12.copyWith(color:EvieColors.darkWhite),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }
}

