
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:evie_test/widgets/evie_appbar.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';


import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../api/length.dart';
import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_button.dart';
import '../../widgets/page_widget/qr_scanner_overlay.dart';



class QRScanning extends StatefulWidget {
  const QRScanning({Key? key}) : super(key: key);

  @override
  _QRScanningState createState() => _QRScanningState();
}

class _QRScanningState extends State<QRScanning> {

  late MobileScannerController cameraController;

  late BikeProvider _bikeProvider;

  @override
  void initState() {
   cameraController = MobileScannerController();
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 184.h,
      height: 184.h,
    );

    _bikeProvider = Provider.of<BikeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        body: Stack(
            children:[

              MobileScanner(
                fit: BoxFit.cover,
                scanWindow: scanWindow,
                controller: cameraController,
                onDetect: (BarcodeCapture barcode) async {

                 for (var element in barcode.barcodes) {
                      cameraController.stop();
                     final String code = element.rawValue!;
                     debugPrint('Barcode found, $code');

                     SmartDialog.showLoading();
                     _bikeProvider.handleBarcodeData(code);

                     await _bikeProvider.handleBarcodeData(code);
                     if (_bikeProvider.scanQRCodeResult ==
                         ScanQRCodeResult.success) {
                       SmartDialog.dismiss(status: SmartStatus.loading);
                       changeToBikeConnectSuccessScreen(context);
                     } else {
                       SmartDialog.dismiss(status: SmartStatus.loading);
                       changeToBikeConnectFailedScreen(context);
                     }

                     ///get serial number
                     ///handle code pass to bike provider
                     ///Detect bike exist from reference, the validation code correct
                     ///Detect is first user
                     ///upload to userbike and bikeuser list

                   }


                }
                ),



     // MobileScanner(
     //
     //              fit: BoxFit.cover,
     //              allowDuplicates: false,
     //              scan
     //              controller: cameraController,
     //              onDetect: (barcode, args) async {
     //
     //                if (barcode.rawValue == null) {
     //                  debugPrint('Failed to scan Barcode');
     //                } else {
     //                  final String code = barcode.rawValue!;
     //                  debugPrint('Barcode found, $code');
     //
     //                  SmartDialog.showLoading();
     //                  _bikeProvider.handleBarcodeData(code);
     //
     //                  await _bikeProvider.handleBarcodeData(code);
     //                  if(_bikeProvider.scanQRCodeResult == ScanQRCodeResult.success){
     //
     //                    SmartDialog.dismiss(status:SmartStatus.loading);
     //                    changeToBikeConnectSuccessScreen(context);
     //                  }else{
     //                    SmartDialog.dismiss(status:SmartStatus.loading);
     //                    changeToBikeConnectFailedScreen(context);
     //                  }
     //
     //                  ///get serial number
     //                  ///handle code pass to bike provider
     //                  ///Detect bike exist from reference, the validation code correct
     //                  ///Detect is first user
     //                  ///upload to userbike and bikeuser list
     //
     //                }
     //              }),



              Positioned.fill(
                child: Container(
                  height:10,
                  width: 20,
                  decoration: ShapeDecoration(
                    shape: QrScannerOverlayShape(
                      borderColor: Colors.white,
                      borderRadius: 10,
                      borderLength: 20,
                      borderWidth: 5,
                      cutOutSize: 184.h,
                    ),
                  ),

                ),
              ),





    Align(
    alignment: Alignment.bottomCenter,
    child:Padding(
          padding:       EdgeInsets.only(left: 16.w, right: 16.w, bottom: 180.h),
          child: IconButton(
            iconSize: 64.h,
              icon:  Image(
                image: const AssetImage("assets/buttons/torch.png"),
                height: 64.h,
                width: 64.w,
              ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ),
    ),


              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 153.h, 20.w, 123.h),
                child: Text(
                  "Align the QR code within the frame to scan",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),

        Align(
            alignment: Alignment.bottomCenter,
        child:Padding(
          padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w,132.h),
          child: Text(
            "Or",
            style: TextStyle(fontSize: 16.sp, color: Colors.white),
          ),
        ),
        ),


              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                  EdgeInsets.only(left: 16.0.w, right: 16.w, bottom:56.h),
                  child:  EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Add Manually",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    onPressed: () async {
                      changeToQRAddManuallyScreen(context);
                    },
                  ),
                ),
              ),

            ]

        ),


      ),
    );
  }
}



