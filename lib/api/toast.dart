import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import '../bluetooth/modelResult.dart';
import 'model/bike_model.dart';

showConnectionStatusToast(BluetoothProvider _bluetoothProvider, bool isFirstTimeConnected, double bottomPadding) {
  DeviceConnectResult? deviceConnectResult = _bluetoothProvider.deviceConnectResult;
  switch(deviceConnectResult) {
    case DeviceConnectResult.scanning:
      Future.delayed(Duration.zero).then((value) {
        return SmartDialog.dismiss(status: SmartStatus.allToast).then((value) => showConnectingToast(bottomPadding));
      });
      break;
    case DeviceConnectResult.scanTimeout:
      Future.delayed(Duration.zero).then((value) {
        _bluetoothProvider.clearDeviceConnectStatus();
        return SmartDialog.dismiss(status: SmartStatus.allToast).then((value) => showScanTimeoutToast(bottomPadding));
      });
      break;
    case DeviceConnectResult.scanError:
      Future.delayed(Duration.zero).then((value) {
        _bluetoothProvider.clearDeviceConnectStatus();
        return SmartDialog.dismiss(status: SmartStatus.allToast).then((value) => showScanErrorToast(bottomPadding));
      });
      break;
    case DeviceConnectResult.connected:
      if (!isFirstTimeConnected) {
        Future.delayed(Duration.zero).then((value) {
          return SmartDialog.dismiss(status: SmartStatus.allToast).then((
              value) => showConnectedToast(bottomPadding));
        });
      }
      break;
    case DeviceConnectResult.disconnected:
      Future.delayed(Duration.zero).then((value) {
        _bluetoothProvider.clearDeviceConnectStatus();
        return SmartDialog.dismiss(status: SmartStatus.allToast).then((value) => showDisconnectedToast(bottomPadding));
      });
      break;
    case DeviceConnectResult.connectError:
      Future.delayed(Duration.zero).then((value) {
        _bluetoothProvider.clearDeviceConnectStatus();
        return SmartDialog.dismiss(status: SmartStatus.allToast).then((value) => showConnectErrorToast(bottomPadding));
      });
      break;
    case DeviceConnectResult.connecting:
      // TODO: Handle this case.
      break;
    case DeviceConnectResult.partialConnected:
      // TODO: Handle this case.
      break;
    case DeviceConnectResult.disconnecting:
      // TODO: Handle this case.
      break;
  }
}

showConnectedToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container (
              width: 358.w,
              alignment: Alignment.centerLeft,
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            ),
          )
      ));
}

showConnectingToast(double bottomPadding) {
  SmartDialog.showToast("",
      isLoadingTemp: true,
      time: Duration(seconds: 30),
      alignment: Alignment.topCenter,
      widget: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 358.w,
              alignment: Alignment.centerLeft,
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/loading.svg"),
                    SizedBox(width: 4.w,),
                    Text(
                      "Connecting bike.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            )
        ),
      )
  );
}

showScanTimeoutToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.bottomLeft,
      widget: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          height: double.infinity,
          child: Wrap(
            children: [
              Container(
                width: 358.w,
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 0.w, 8.h),
                  child: Row(
                    children: [
                      Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                      SizedBox(width: 12.w,),
                      Container(
                        width: 300.w,
                        height: 44.h,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      )
  );
}

showScanErrorToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 358.w,
              alignment: Alignment.centerLeft,
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  children: [
                    Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                    SizedBox(width: 4.w,),
                    Text(
                      "Scan Error. Please re-enabled your bluetooth.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            )
        ),
      )
  );
}

showConnectErrorToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 358.w,
              alignment: Alignment.centerLeft,
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  children: [
                    Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                    SizedBox(width: 4.w,),
                    Text(
                      "Connect Error. Please try again.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            )
        ),
      )
  );
}

showDisconnectedToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 358.w,
              alignment: Alignment.centerLeft,
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  children: [
                    Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
                    SizedBox(width: 4.w,),
                    Text(
                      "Bike disconnected.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            )
        ),
      )
  );
}

showControlAdmissionToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.bottomLeft,
      widget: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          height: double.infinity,
          child: Wrap(
            children: [
              Container(
                width: 358.w,
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 0.w, 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 320.w,
                        height: 44.h,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      )
  );
}

showUpdatedPasswordToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.topCenter,
      widget: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container (
              width: 358.w,
              alignment: Alignment.centerLeft,
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/check.svg"),
                    SizedBox(width: 4.w,),
                    Text(
                      "Your password has been updated.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Colors.black,
              ),
            ),
          )
      ));
}

showUpgradePlanToast(double bottomPadding) {
  SmartDialog.showToast("",
      alignment: Alignment.bottomLeft,
      widget: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          height: double.infinity,
          child: Wrap(
            children: [
              Container(
                width: 358.w,
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 0.w, 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 320.w,
                        height: 60.h,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      )
  );
}
