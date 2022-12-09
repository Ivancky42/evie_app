
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/screen/onboarding/bike_connect_failed.dart';
import 'package:evie_test/screen/onboarding/bike_connect_success.dart';
import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../api/provider/bike_provider.dart';



class QRScanning extends StatefulWidget {
  const QRScanning({Key? key}) : super(key: key);

  @override
  _QRScanningState createState() => _QRScanningState();
}

class _QRScanningState extends State<QRScanning> {

  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        body: Column(
            children:[

              Container(
                height: 300.h,
                child: MobileScanner(
                  fit: BoxFit.fill,
                    allowDuplicates: false,
                    controller: MobileScannerController(
                        facing: CameraFacing.back, torchEnabled: false, ),
                    onDetect: (barcode, args) {
                      if (barcode.rawValue == null) {
                        debugPrint('Failed to scan Barcode');
                      } else {
                        final String code = barcode.rawValue!;
                        debugPrint('Barcode found, $code');

                        SmartDialog.showLoading();
                        _bikeProvider.handleBarcodeData(code);


                        FutureBuilder(
                            future: _bikeProvider.getQRCodeResult(),
                            builder: (_, snapshot) {
                              if (snapshot.data != ScanQRCodeResult.unknown) {

                                _bikeProvider.setQRCodeResult(ScanQRCodeResult.unknown);
                                if(snapshot.data == ScanQRCodeResult.success){

                                 return BikeConnectSuccess();
                                }else{

                                  return BikeConnectFailed();
                                }




                              } else {
                                return const CircularProgressIndicator();
                              }
                            });


                        //get serial number

                        ///handle code pass to bike provider
                        ///Detect bike exist from reference, the validation code correct
                        ///Detect is first user
                        ///upload to userbike and bikeuser list

                      }
                    }),
              )

            ]

        ),


      ),
    );
  }



}
