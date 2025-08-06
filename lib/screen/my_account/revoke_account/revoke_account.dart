import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/length.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/api/provider/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/dialog.dart';
import '../../../api/navigator.dart';
import '../../../widgets/evie_appbar.dart';

///User profile page with user account information

class RevokeAccount extends StatefulWidget {
  const RevokeAccount({super.key});

  @override
  _RevokeAccountState createState() => _RevokeAccountState();
}

class _RevokeAccountState extends State<RevokeAccount> {

  late AuthProvider _authProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authProvider = context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppbar(
        title: 'Revoke Account',
        onPressed: () {
          back(context, RevokeAccount());
        },
      ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, EvieLength.target_reference_button_a),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Permanently delete account', style: EvieTextStyles.h2.copyWith(fontWeight: FontWeight.w500),),
                  Text(
                    'The account will no longer be available, and all data in the account will be permanently deleted. Are you sure you would like to revoke account?',
                    style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.w400),
                  )
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                          'Revoke Account',
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),
                        onPressed: () async {
                          showRevokeAccountDialog(context, _authProvider);
                        }
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: EvieButton_ReversedColor(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        'Cancel',
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor),
                      ),
                      onPressed: () {
                        changeToMyAccount(context, RevokeAccount());
                      },
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
