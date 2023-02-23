import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import '../bluetooth/modelResult.dart';
import 'model/bike_model.dart';

showConnectionStatusToast(
    BluetoothProvider _bluetoothProvider,
    bool isFirstTimeConnected,
    context,
    ScaffoldMessengerState _navigator
    ) {
    DeviceConnectResult? deviceConnectResult = _bluetoothProvider.deviceConnectResult;
    switch(deviceConnectResult) {
      case DeviceConnectResult.scanning:
        Future.delayed(Duration.zero).then((value) {
          _navigator.removeCurrentSnackBar();
          return showConnectingToast(context);
        });
        break;
      case DeviceConnectResult.scanTimeout:
        Future.delayed(Duration.zero).then((value) {
          _navigator.removeCurrentSnackBar();
          _bluetoothProvider.clearDeviceConnectStatus();
          return showScanTimeoutToast(context);
        });
        break;
      case DeviceConnectResult.scanError:
        Future.delayed(Duration.zero).then((value) {
          _navigator.removeCurrentSnackBar();
          _bluetoothProvider.clearDeviceConnectStatus();
          return showScanErrorToast(context);
        });
        break;
      case DeviceConnectResult.connected:
        if (!isFirstTimeConnected) {
          Future.delayed(Duration.zero).then((value) {
            _navigator.removeCurrentSnackBar();
            return showConnectedToast(context);
          });
        }
        break;
      case DeviceConnectResult.disconnected:
        Future.delayed(Duration.zero).then((value) {
          _navigator.removeCurrentSnackBar();
          _bluetoothProvider.clearDeviceConnectStatus();
          return showDisconnectedToast(context);
        });
        break;
      case DeviceConnectResult.connectError:
        Future.delayed(Duration.zero).then((value) {
          _navigator.removeCurrentSnackBar();
          _bluetoothProvider.clearDeviceConnectStatus();
          return showConnectErrorToast(context);
        });
        break;
    }
}

showConnectedToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SvgPicture.asset("assets/icons/check.svg"),
            SizedBox(width: 4.w,),
            Text(
              "Bike Connected.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showConnectingToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SvgPicture.asset("assets/icons/loading.svg"),
            SizedBox(width: 4.w,),
            Text(
              "Connecting bike.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 30),
    ),
  );
}





showScanTimeoutToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
            SizedBox(width: 4.w,),
            Container(
              width: 300.w,
              child: Text(
                "Fail to connect your bike. Please stay close to your bike and connect again.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showScanErrorToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
            SizedBox(width: 4.w,),
            Container(
              width: 300.w,
              child: Text(
                "Scan Error. Please re-enabled your bluetooth.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showConnectErrorToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
            SizedBox(width: 4.w,),
            Container(
              width: 300.w,
              child: Text(
                "Connect Error. Please try again.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showDisconnectedToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
            SizedBox(width: 4.w,),
            Container(
              width: 300.w,
              child: Text(
                "Bike Disconnected.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showControlAdmissionToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 4.w,),
            Container(
              width: 300.w,
              child: Text(
                "Your account doesn't have control admission for this setting.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showUpgradePlanToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 4.w,),
            Container(
              width: 300.w,
              child: Text(
                "This feature only available for pro plan user. You can upgrade your plan in setting page. ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showOnlyForProToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
            SizedBox(width: 4.w,),
            Container(
              width: 300.w,
              child: Text(
                "This feature only available for pro plan user. You can upgrade your plan in setting page.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

hideCurrentSnackBar(ScaffoldMessengerState _navigator) {
  Future.delayed(Duration.zero).then((value) {
    _navigator.removeCurrentSnackBar();
  });
}

