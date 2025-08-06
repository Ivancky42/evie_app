
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:flutter/material.dart';



class TestQRScan extends StatefulWidget {
  const TestQRScan({super.key});

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
