import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bluetooth/modelResult.dart';
import 'colours.dart';
import 'enumerate.dart';
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
      case DeviceConnectResult.connecting:
        // TODO: Handle this case.
        break;
      case DeviceConnectResult.partialConnected:
        // TODO: Handle this case.
        break;
      case DeviceConnectResult.disconnecting:
        // TODO: Handle this case.
        break;
      case DeviceConnectResult.switchBike:
        Future.delayed(Duration.zero).then((value) {
          _navigator.removeCurrentSnackBar();
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
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Padding(
                  padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Bike connected.",
                  style: EvieTextStyles.toast,
                ),
              ),
            ],
          ),
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
      elevation: 0,
      content:  GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Container(
          alignment: Alignment.center,
          //color: Colors.green,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 30.w,
                height: 30.w,
                child: Lottie.asset('assets/animations/loading-button-grey.json', repeat: true),
              ),
              SizedBox(width: 4.w,),
              Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    "Connecting bike.",
                    style: EvieTextStyles.toast,
                  ),
              )
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 12),
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
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: Row(
          children: [
            SvgPicture.asset("assets/icons/fail.svg"),
            SizedBox(width: 4.w,),
            Flexible(
              child: Text(
                "We couldn’t connect to your bike. Stay close and reconnect.",
                style: EvieTextStyles.toast,
              ),
            ),
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
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: Row(
          children: [
            SvgPicture.asset("assets/icons/fail.svg"),
            SizedBox(width: 4.w,),
            Flexible(
              child: Text(
                "Scan Error. Please re-enabled your bluetooth.",
                style: EvieTextStyles.toast,
              ),
            ),
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
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: Row(
          children: [
            SvgPicture.asset("assets/icons/fail.svg"),
            SizedBox(width: 4.w,),
            Flexible(
              child: Text(
                "Connection failed. Make sure you are near to your bike and try again.",
                style: EvieTextStyles.toast,
              ),
            ),
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
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: Row(
          children: [
            SvgPicture.asset("assets/icons/fail.svg"),
            SizedBox(width: 4.w,),
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Flexible(
                child: Text(
                  "Bike disconnected.",
                  style: EvieTextStyles.toast,
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

showToLockBikeInstructionToast(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Row(
          children: [
            Flexible(
              child: Text(
                "Bike is unlocked. To lock bike, pull the lock handle on the bike.",
                style: EvieTextStyles.toast,
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

// showUpgradePlanToast(context, SettingProvider settingProvider){
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//           borderRadius:
//           BorderRadius.all(Radius.circular(10)
//           )
//       ),
//       content: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child:Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//              Column(
//                   children: [
//                     Text(
//                         "Limited access. Upgrade your plan to access this feature.",
//                         style: EvieTextStyles.toast,
//                       ),
//                     Align(
//                       alignment: Alignment.bottomRight,
//                         child: TextButton(
//                           onPressed: () {
//                             settingProvider.changeSheetElement(SheetList.proPlan);
//                           },
//                           child: Text(
//                             "UNLOCK FEATURE NOW",
//                             style: EvieTextStyles.body16.copyWith(
//                               color: EvieColors.strongPurple,
//                               fontWeight: FontWeight.w900,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//
//           ],
//         ),
//       ),
//       duration: const Duration(seconds: 2),
//     ),
//   );
// }

showUpgradePlanToast(context, SettingProvider settingProvider,[bool? isPop]){
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 2, 12.w, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                child: Text(
                  "Limited access. Upgrade your plan to access this feature.",
                  style: EvieTextStyles.toast,
                ),
              ),
              SizedBox(height: 4.h,),
              Container(
                //width: 170.w,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    if(isPop == true){
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      settingProvider.changeSheetElement(SheetList.proPlan);
                      showSheetNavigate(context);
                    }else{
                      settingProvider.changeSheetElement(SheetList.proPlan);
                    }
                  },
                  child: Text(
                    "UNLOCK FEATURE NOW",
                    style: EvieTextStyles.body16.copyWith(
                      color: EvieColors.strongPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}




showControlAdmissionToast(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                width: 300.w,
                child: Text(
                  "Limited access. Upgrade your plan to access this feature.",
                  style: EvieTextStyles.toast,
                ),
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showOnlyForProToast(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Image.asset("assets/icons/connect_failed.png", width: 16.w, height: 16.h,),
              SizedBox(width: 4.w,),
              Container(
                width: 300.w,
                child: Text(
                  "This feature only available for pro plan user. You can upgrade your plan in setting page.",
                  style: EvieTextStyles.toast,
                ),
              )
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

showAccNoPermissionToast(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 315.w,
                child: Text(
                  "Apologies, pal, you don't have the permission to manage this setting.",
                  style: EvieTextStyles.toast,
                ),
              )
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

showResentEmailFailedToast(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Row(
          children: [
            Container(
              width: 300.w,
              child: Text(
                "You may request to resend email in another 30 seconds.",
                style: EvieTextStyles.toast,
              ),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showBikeAddSuccessfulToast(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Text(
                "Bike added successfully!",
                style: EvieTextStyles.toast,
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

showEVRemovedToast(context, String keyName) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 300.w,
                child: Text(
                  "${keyName} have been removed from your EV-Key list.",
                  style: EvieTextStyles.toast,
                ),
              )
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

showScanTimeOut(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Text(
                "Scan timeout. Please stay close to your bike and connect again.",
                style: EvieTextStyles.toast,
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showUpdatedPasswordToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Text(
                "Your password has been updated.",
                style: EvieTextStyles.toast,
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showRemoveUserToast(context, msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                msg,
                style: EvieTextStyles.toast,
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showRecoveringModeToast(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Text(
                "Successfully entered recovery mode.",
                style: EvieTextStyles.toast,
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showPermissionNeeded(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          openAppSettings();
        },
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    "Your device notifications are off. Turn on notifications to ensure you don’t miss any updates. ",
                    style: EvieTextStyles.toast,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "OPEN SETTINGS",
                style: EvieTextStyles.body16.copyWith(
                  color: EvieColors.strongPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        )
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

showUpdateMetric(context, settingName) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Text(
                "Updated to " + settingName,
                style: EvieTextStyles.toast,
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showEVSuccess(context, message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Text(
                message,
                style: EvieTextStyles.toast,
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

showSucccessUpdateBikeName(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          //Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Name Updated!",
                  style: EvieTextStyles.toast,
                ),
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 4),
    ),
  );
}

showFailUpdateBikeName(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: Row(
          children: [
            SvgPicture.asset("assets/icons/fail.svg"),
            SizedBox(width: 4.w,),
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Flexible(
                child: Text(
                  "Failed to update bike name. Please try again later.",
                  style: EvieTextStyles.toast,
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

showTheftDismiss(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(10)
          )
      ),
      elevation: 0,
      content: GestureDetector(
        onTap: () {
          Future.delayed(Duration.zero).then((value) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SvgPicture.asset("assets/icons/check.svg"),
              SizedBox(width: 4.w,),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Theft attempt mode dismissed.",
                  style: EvieTextStyles.toast,
                ),
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

hideCurrentSnackBar(ScaffoldMessengerState _navigator) {
  Future.delayed(Duration.zero).then((value) {
    _navigator.removeCurrentSnackBar();
  });
}

