
import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/shared_pref_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/navigator.dart';

class ThreatBikeRecovered extends StatefulWidget {
  const ThreatBikeRecovered({super.key});

  @override
  _ThreatBikeRecoveredState createState() => _ThreatBikeRecoveredState();
}

class _ThreatBikeRecoveredState extends State<ThreatBikeRecovered> with WidgetsBindingObserver {

  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  late SharedPreferenceProvider _sharedPreferenceProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sharedPreferenceProvider = context.read<SharedPreferenceProvider>();
    _bikeProvider = context.read<BikeProvider>();
    String deviceIMEI = _bikeProvider.currentBikeModel!.deviceIMEI!;
    _sharedPreferenceProvider.handleSubTopic("$deviceIMEI~unlock", false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    String deviceIMEI = _bikeProvider.currentBikeModel!.deviceIMEI!;
    _sharedPreferenceProvider.handleSubTopic("$deviceIMEI~unlock", true);
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
          body: Stack(
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 120.h, 16.w,4.h),
                          child: Text(
                            "Bike Recovered!",
                            style: EvieTextStyles.h2,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 153.h),
                          child: Text(
                            "Your bike in back in your possession after a theft attempt. "
                                "Ensure ${_bikeProvider.currentBikeModel!.deviceName}'s security and enjoy it once again.",
                            style: EvieTextStyles.body18,
                          ),
                        ),

                        Center(
                          child: SvgPicture.asset(
                            "assets/images/bike_champion.svg",
                            height: 242.34.h,
                            width: 252.17.w,
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: EvieLength.target_reference_button_a),
                      child:  EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                          "Hooray!",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                        ),

                        onPressed: (){

                          changeToUserHomePageScreen(context);
                        },
                      ),
                    ),
                  ]
              ),
              Lottie.asset(
                'assets/animations/confetti.json',
                repeat: false,
              ),
            ],
          ),
      ),
    );
  }
}
