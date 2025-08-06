import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/screen/my_account/account/account_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/function.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../bluetooth/modelResult.dart';

class AccountContainer extends StatefulWidget {
  final AccountModel accountModel;
  const AccountContainer({super.key, required this.accountModel});

  @override
  State<AccountContainer> createState() => _AccountContainerState();
}

class _AccountContainerState extends State<AccountContainer> {

  late BikeProvider _bikeProvider;
  late AuthProvider _authProvider;
  late SettingProvider _settingProvider;
  late NotificationProvider _notificationProvider;
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
    _notificationProvider = Provider.of<NotificationProvider>(context);

    switch(label) {
      case "Personal Information":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeToEditProfile(context);
              },
              child: SizedBox(
                height: 54.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/my_account/personal-detail.svg', width: 28.w, height: 28.w,),
                            SizedBox(width: 8.w,),
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
            Container(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(52.w, 0, 0, 0),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Push Notifications":
        return Column(
          children: [
            SizedBox(
              child: Container(
                color: EvieColors.dividerWhite,
                height: 12.h,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                changeToPushNotification(context);
              },
              child: SizedBox(
                height: 54.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/my_account/push-notification.svg', width: 28.w, height: 28.w,),
                            SizedBox(width: 8.w,),
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
            Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 52.w),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
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
              child: SizedBox(
                height: 54.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/my_account/display-setting.svg', width: 28.w, height: 28.w,),
                            SizedBox(width: 8.w,),
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
            Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 52.w),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Help Center":
        return Column(
          children: [
            SizedBox(
              child: Container(
                color: EvieColors.dividerWhite,
                height: 12.h,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                const url = 'https://support.eviebikes.com/en-US';
                final Uri url0 = Uri.parse(url);
                launch(url0);
              },
              child: SizedBox(
                height: 54.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/my_account/help-center.svg', width: 28.w, height: 28.w,),
                            SizedBox(width: 8.w,),
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
            Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 52.w),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Privacy Policies":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                const url = 'https://eviebikes.com/policies/privacy-policy';
                final Uri url0 = Uri.parse(url);
                launch(url0);
              },
              child: SizedBox(
                height: 54.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/my_account/privacy.svg', width: 28.w, height: 28.w,),
                            SizedBox(width: 8.w,),
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
            Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 52.w),
                  child: Divider(
                    thickness: 0.2.h,
                    color: EvieColors.darkWhite,
                    height: 0,
                  ),
                )
            ),
          ],
        );
      case "Terms of Service":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                const url = 'https://eviebikes.com/policies/terms-of-service';
                final Uri url0 = Uri.parse(url);
                launch(url0);
              },
              child: SizedBox(
                height: 54.h,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/my_account/term-service.svg', width: 28.w, height: 28.w,),
                            SizedBox(width: 8.w,),
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
            Container(
              child: Padding(
                padding: EdgeInsets.only(left: 52.w),
                child: Divider(
                  thickness: 0.2.h,
                  color: EvieColors.darkWhite,
                  height: 0,
                ),
              )
            ),

            Padding(
              padding: EdgeInsets.only(
                  left: 16.w, right: 16.w, top: 24.h, bottom: 8.h),
              child: SizedBox(
                height: 48.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    showLogoutDialog(context, _authProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side:  BorderSide(color: EvieColors.darkGrayish, width: 1.5.w)),
                    elevation: 0.0,
                    backgroundColor: EvieColors.transparent,
                  ),
                  child: Text(
                    "Logout",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 16.w, right: 16.w, top: 0.h, bottom: 18.h),
              child: SizedBox(
                height: 48.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ()  async {
                    changeToRevokeAccount(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side:  BorderSide(color: EvieColors.darkGrayish, width: 1.5.w)),
                    elevation: 0.0,
                    backgroundColor: EvieColors.transparent,

                  ),
                  child: Text(
                    "Revoke Account",
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.darkGrayish),
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
                      "${_settingProvider.packageInfo?.appName ?? "EVIE Bikes"} ${_settingProvider.packageInfo?.version ?? "v1.0.0"} (${_settingProvider.packageInfo?.buildNumber ?? "0"})",
                      style: EvieTextStyles.body12.copyWith(color:EvieColors.darkWhite),
                    ),
                    Text(
                      "Copyright 2024 by EVIE Bikes ApS",
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

