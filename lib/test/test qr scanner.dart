
import 'package:evie_bike/api/navigator.dart';
import 'package:evie_bike/widgets/evie_appbar.dart';
import 'package:flutter/material.dart';
import 'package:evie_bike/api/provider/current_user_provider.dart';

import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/evie_button.dart';


class TestQRScan extends StatefulWidget {
  const TestQRScan({Key? key}) : super(key: key);

  @override
  _TestQRScanState createState() => _TestQRScanState();
}

class _TestQRScanState extends State<TestQRScan> {


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        appBar: EvieAppbar_Back(
            onPressed: (){changeToTestBLEScreen(context);}
        ),
          body: Column(
          children:[

            // Container(
            //   height: 300.h,
            //   child: MobileScanner(
            //       allowDuplicates: false,
            //       controller: MobileScannerController(
            //           facing: CameraFacing.back, torchEnabled: false),
            //       onDetect: (barcode, args) {
            //         if (barcode.rawValue == null) {
            //           debugPrint('Failed to scan Barcode');
            //         } else {
            //           final String code = barcode.rawValue!;
            //           debugPrint('Barcode found! $code');
            //         }
            //       }),
            // )

          ]

          ),


      ),
    );
  }



}
