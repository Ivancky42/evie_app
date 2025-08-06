import 'package:evie_test/api/enumerate.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../widgets/evie_progress_indicator.dart';


class InvitationSent extends StatefulWidget{
  const InvitationSent({ super.key });
  @override
  _InvitationSentState createState() => _InvitationSentState();
}

class _InvitationSentState extends State<InvitationSent> {

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

        child: Scaffold(
          body: Stack(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 21.h),
                        child: EvieProgressIndicator(currentPageNumber: 2, totalSteps: 3,),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 21.h, 16.w, 4.h),
                        child: Text(
                          "Invitation Sent",
                          style: EvieTextStyles.h2,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w,4.h,16.w,4.h),
                        child: Container(
                          child: Text.rich(
                            TextSpan(
                              text: "Hooray! EVIE have sent the invitation to ",
                              style: EvieTextStyles.body18,
                              children: [
                                TextSpan(
                                  text: _settingProvider.stringPassing,
                                  style: TextStyle(
                                    color: EvieColors.primaryColor, // Set your desired color
                                    // Other styles if needed
                                  ),
                                ),
                                TextSpan(
                                  text: ". Let's enjoy the ride together.",
                                  style: EvieTextStyles.body18,
                                ),
                              ],
                            ),
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
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.target_reference_button_a),
                    child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        _settingProvider.changeSheetElement(SheetList.pedalPalsList, _bikeProvider.currentBikeModel?.deviceIMEI);
                      },
                    ),
                  ),
                ),
              ]),
        ));
  }
}