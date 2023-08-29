import 'package:evie_test/api/enumerate.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/fonts.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../widgets/evie_progress_indicator.dart';


class InvitationSent extends StatefulWidget{
  const InvitationSent({ Key? key }) : super(key: key);
  @override
  _InvitationSentState createState() => _InvitationSentState();
}

class _InvitationSentState extends State<InvitationSent> {

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
                          child: Text(
                          //  "Hooray! EVIE have sent invitation to ${widget.email}. Let's enjoy the ride together",
                            "Hooray! EVIE have sent the invitation to ${_settingProvider.stringPassing}. Let's enjoy the ride together",
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
                    padding: EdgeInsets.fromLTRB(16.w,127.84.h,16.w, EvieLength.button_Bottom),
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
                        _settingProvider.changeSheetElement(SheetList.pedalPalsList);
                      },
                    ),
                  ),
                ),
              ]),
        ));
  }
}