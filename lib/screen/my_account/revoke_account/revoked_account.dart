import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/auth_provider.dart';

class RevokedAccount extends StatefulWidget {
  const RevokedAccount({Key? key}) : super(key: key);

  @override
  State<RevokedAccount> createState() => _RevokedAccountState();
}

class _RevokedAccountState extends State<RevokedAccount> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 3));
    changeToWelcomeScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: EvieColors.grayishWhite,
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 67.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account deleted!', style: EvieTextStyles.h2.copyWith(fontSize: 26.sp, fontWeight: FontWeight.w500),),
                Text(
                  'Goodbye! We\'re sorry to see you go. Your account has been successfully deleted.',
                  style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 111.h,
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child: Container(
                //     height: 155.h,
                //     width: 252.h,
                //     child: Lottie.asset(
                //       'assets/animations/revoke-account.json',
                //       repeat: true,
                //       height: 155.h,
                //       width: 252.h,
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
              ],
            ),
          )
      ),
    );
  }
}
