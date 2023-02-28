import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_progress_indicator.dart';
import '../../widgets/evie_textform.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    final TextEditingController _bikeNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        changeToUserHomePageScreen(context);
        return false;
      },

      child: Scaffold(
        body: Column(
          children: [

            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w,221.h),
                child: Center(
                  child:  Lottie.asset('assets/animations/error-animate.json'),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
