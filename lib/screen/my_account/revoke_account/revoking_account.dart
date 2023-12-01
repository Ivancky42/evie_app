import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/fonts.dart';

class RevokingAccount extends StatefulWidget {
  const RevokingAccount({Key? key}) : super(key: key);

  @override
  State<RevokingAccount> createState() => _RevokingAccountState();
}

class _RevokingAccountState extends State<RevokingAccount> {
  late AuthProvider _authProvider;
  late CurrentUserProvider _currentUserProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _authProvider = context.read<AuthProvider>();
    String? currentUid = _authProvider.getUid;
    _currentUserProvider = context.read<CurrentUserProvider>();
    await _authProvider.deactivateAccount();
    final result = await _currentUserProvider.listenIsDeactivated(currentUid!);
    if (result == 'Success') {
      await _authProvider.signOut(context);
      await Future.delayed(const Duration(seconds: 3));
      changeToRevokedAccount(context);
    }
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
                Text('Revoking account', style: EvieTextStyles.h2.copyWith(fontSize: 26.sp, fontWeight: FontWeight.w500),),
                Text(
                  'Hold tight! Revoking your account may take a bit of time, but rest assured we\'re working on it. Thank you for your patience.',
                  style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 111.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 155.h,
                    width: 252.h,
                    child: Lottie.asset(
                      'assets/animations/revoke-account.json',
                      repeat: true,
                      height: 155.h,
                      width: 252.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
