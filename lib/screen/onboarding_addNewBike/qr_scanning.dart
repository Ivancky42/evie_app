import 'dart:async';

import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import '../../api/colours.dart';
import '../../api/dialog.dart';
import '../../api/fonts.dart';
import '../../api/length.dart';
import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_button.dart';
import '../../widgets/page_widget/qr_scanner_overlay.dart';

class QRScanning extends StatefulWidget {
  const QRScanning({super.key});

  @override
  _QRScanningState createState() => _QRScanningState();
}

class _QRScanningState extends State<QRScanning> with WidgetsBindingObserver {

  final MobileScannerController cameraController = MobileScannerController(
    // required options for the scanner
  );
  late AuthProvider _authProvider;
  late BikeProvider _bikeProvider;
  bool onTorch = false;
  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = cameraController.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(cameraController.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
      // Restart the scanner when the app is resumed.
      // Don't forget to resume listening to the barcode events.
        _subscription = cameraController.barcodes.listen(_handleBarcode);

        unawaited(cameraController.start());
      case AppLifecycleState.inactive:
      // Stop the scanner when the app is paused.
      // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(cameraController.stop());
    }
  }


  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await cameraController.dispose();
  }

  bool isCameraEnable = false;

  Future<void> _handleBarcode(BarcodeCapture barcode) async {
    for (var element in barcode.barcodes) {
      cameraController.stop();
      final String code = element.rawValue!;
      debugPrint('Barcode found, $code');

      showCustomLightLoading();

      await _bikeProvider.handleBarcodeData(code);

      if (_bikeProvider.scanQRCodeResult == ScanQRCodeResult.success) {
        SmartDialog.dismiss(status: SmartStatus.loading);
        changeToRegisteringBikeScreen(context, true, _bikeProvider.registeringDeviceIMEI);
      } else {
        SmartDialog.dismiss(status: SmartStatus.loading);
        changeToRegisteringBikeScreen(context, false, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 184.h,
      height: 184.h,
    );

    checkCameraPermission();

    _authProvider =  Provider.of<AuthProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);


    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        body: Stack(
            children:[
              if (isCameraEnable)...{
                MobileScanner(
                    fit: BoxFit.cover,
                    scanWindow: scanWindow,
                    controller: cameraController,
                ),
              } else...{
                Container(),
              },

              Visibility(
                visible: isCameraEnable,
                child: Positioned.fill(
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
              ),

              Visibility(
                visible: !isCameraEnable,
                child: Positioned.fill(
                  child: Container(
                    color: EvieColors.lightBlack,
                  ),
                ),
              ),


              Align(
                alignment: Alignment.bottomCenter,
                child:Padding(
                  padding:  EdgeInsets.only(left: 16.w, right: 16.w, bottom: 180.h),
                  child: IconButton(
                      iconSize: 64.h,
                      icon:  onTorch ? Image(
                        image: const AssetImage("assets/buttons/torch_on.png"),
                        height: 64.h,
                        width: 64.w,
                      ) : Image(
                        image: const AssetImage("assets/buttons/torch.png"),
                        height: 64.h,
                        width: 64.w,
                      ),
                      onPressed: () {

                        setState(() {
                          onTorch = !onTorch;
                        });
                        cameraController.toggleTorch();
                      }

                  ),
                ),
              ),



              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 71.h, 20.w, 123.h),
                    child:   GestureDetector(
                      onTap: (){
                        _authProvider.setIsFirstLogin(false);
                        _bikeProvider.setIsAddBike(false);

                        showEvieExitRegistrationDialog(context);
                      },
                      child: SvgPicture.asset(
                        "assets/buttons/close.svg",
                      ),
                    ),
                  ),
                ],
              ),

                ///camera access not granted
                Visibility(
                  visible: !isCameraEnable,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 276.h, 20.w, 123.h),
                        child: Column(
                          children: [
                            Text(
                              "Let EVIE App access your camera in",
                              style: TextStyle(fontSize: 16.sp, color: Colors.white),
                            ),
                            Text(
                              "order to scan ownership QR code.",
                              style: TextStyle(fontSize: 16.sp, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: !isCameraEnable,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 375.h, 20.w, 123.h),
                        child: TextButton(
                          onPressed: () async {
                            if (await Permission.camera.request().isDenied) {
                            } else if (await Permission.camera.request().isPermanentlyDenied){
                              showEvieCameraSettingDialog(context);
                            }
                          },

                          child: Text("Enable Camera Access",
                            style: EvieTextStyles.body18.copyWith(fontWeight:FontWeight.w900, color: EvieColors.primaryColor, decoration: TextDecoration.underline,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ///camera access granted
                Visibility(
                  visible: isCameraEnable,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 153.h, 20.w, 123.h),
                        child: Text(
                          "Align the QR code within the frame to scan",
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: isCameraEnable,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 190.h, 20.w, 123.h),
                        child: TextButton(
                          onPressed: (){
                            showEvieFindQRDialog(context);
                          },
                          child: Text("Where to find QR code?",
                            style: EvieTextStyles.body16.copyWith(fontWeight:FontWeight.w900, color: EvieColors.thumbColorTrue, decoration: TextDecoration.underline,),
                          ),
                        ),
                      ),
                    ],
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
                  EdgeInsets.only(left: 16.0.w, right: 16.w, bottom: EvieLength.target_reference_button_a),
                  child:  EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Add Manually",
                      style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
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

  ///ask for camera permission
  Future<void> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        isCameraEnable = true;
      });
    } else {
      setState(() {
        isCameraEnable = false;
      });
    }
  }

  ///check camera permission status
  Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

}



