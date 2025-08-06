import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../widgets/evie_progress_indicator.dart';

class TurnOnQRScanner extends StatefulWidget {
  const TurnOnQRScanner({super.key});

  @override
  _TurnOnQRScannerState createState() => _TurnOnQRScannerState();
}

class _TurnOnQRScannerState extends State<TurnOnQRScanner> {


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
          body: Stack(
              children:[
                Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EvieProgressIndicator(currentPageNumber: 0, totalSteps: 6,),
                            Text(
                              "First up, scan the QR Code",
                              style: EvieTextStyles.h2,
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(
                              "You can find the QR on the ownership card.",
                              style: EvieTextStyles.body18,
                            ),
                            SizedBox(height: 145.h,),
                            Center(
                              child: SvgPicture.asset(
                                "assets/images/scan_qr.svg",
                              ),
                            ),
                          ],
                        ),
                        EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            "Scan QR Code",
                            style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                          ),
                          onPressed: () async{
                            if (await Permission.camera.request().isGranted){
                              changeToQRScanningScreen(context);
                            }else{
                              changeToQRScanningScreen(context);
                              //showCameraDisable();
                            }
                          },
                        ),
                      ],
                    )
                )
              ]
          )
      ),
    );
  }
}
