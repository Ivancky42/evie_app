import 'dart:async';

import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/colours.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/notification_provider.dart';
import '../../../widgets/evie_double_button_dialog.dart';
import '../../../widgets/evie_single_button_dialog.dart';





class ShareBikeLeave extends StatefulWidget {

  final BikeProvider bikeProvider;
  final int index;

  const ShareBikeLeave({
    Key? key,
    required this.bikeProvider,
    required this.index,

  }) : super(key: key);

  @override
  State<ShareBikeLeave> createState() => _ShareBikeLeaveState();
}

class _ShareBikeLeaveState extends State<ShareBikeLeave> {

  late NotificationProvider _notificationProvider;

  @override
  Widget build(BuildContext context) {

    _notificationProvider = Provider.of<NotificationProvider>(context);

    return Container(
      width: 82.w,
      height: 35.h,
      child: ElevatedButton(
        child:    Text(
          "Leave",
          style: TextStyle(
              fontSize: 12.sp,
              color: EvieColors.primaryColor),
        ),
        onPressed: (){
          SmartDialog.show(
              widget: EvieDoubleButtonDialog(
                title: "Are you sure you want to leave",
                childContent: Text('Are you sure you want to leave'),
                leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
                rightContent: "Yes",
                onPressedRight: () async {
                  SmartDialog.dismiss();
                  SmartDialog.showLoading();
                  StreamSubscription? currentSubscription;

                  currentSubscription = widget.bikeProvider.leaveSharedBike(
                  widget.bikeProvider.bikeUserList.values.elementAt(widget.index).uid,
                  widget.bikeProvider.bikeUserList.values.elementAt(widget.index).notificationId!).listen((uploadStatus) {

                    if(uploadStatus == UploadFirestoreResult.success){
                      SmartDialog.dismiss(status: SmartStatus.loading);
                      SmartDialog.show(
                          keepSingle: true,
                          widget: EvieSingleButtonDialog(
                              title: "Success",
                              content: "You leave",
                              rightContent: "Close",
                              onPressedRight: () => SmartDialog.dismiss()
                          ));
                      currentSubscription?.cancel();
                    } else if(uploadStatus == UploadFirestoreResult.failed) {
                      SmartDialog.dismiss();
                      SmartDialog.show(
                          widget: EvieSingleButtonDialog(
                              title: "Not success",
                              content: "Try again",
                              rightContent: "Close",
                              onPressedRight: ()=>SmartDialog.dismiss()
                          ));
                    }else{};
                  },
                  );
                },
              ));
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.w)),
          elevation: 0.0,
          backgroundColor: EvieColors.lightGrayishCyan,
        ),
      ),
    );
  }
}





///Replace with dialog function
// class ShareBikeDelete extends StatefulWidget {
//
//   final BikeProvider bikeProvider;
//   final int index;
//
//   const ShareBikeDelete({
//     Key? key,
//     required this.bikeProvider,
//     required this.index,
//
//   }) : super(key: key);
//
//   @override
//   State<ShareBikeDelete> createState() => _ShareBikeDeleteState();
// }
//
// class _ShareBikeDeleteState extends State<ShareBikeDelete> {
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       width: 107.w,
//       height: 35.h,
//       child: ElevatedButton(
//         child: Row(
//           mainAxisAlignment:
//           MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               "assets/icons/delete.svg",
//               height: 20.h,
//               width: 20.w,
//             ),
//             Text(
//               "Delete",
//               style: TextStyle(
//                   fontSize: 12.sp,
//                   color: EvieColors.grayishWhite),
//             ),
//           ],
//         ),
//         onPressed: (){
//           SmartDialog.show(
//               widget: EvieDoubleButtonDialogCupertino(
//                 title: "Are you sure you want to delete this user",
//                 content: 'Are you sure you want to delete this user',
//                 leftContent: 'Cancel', onPressedLeft: () { SmartDialog.dismiss(); },
//                 rightContent: "Yes",
//                 onPressedRight: () async {
//                   StreamSubscription? currentSubscription;
//
//                   currentSubscription = widget.bikeProvider.removedSharedBikeStatus(
//                       widget.bikeProvider.bikeUserList.values.elementAt(widget.index).uid,
//                       widget.bikeProvider.bikeUserList.values.elementAt(widget.index).notificationId!).listen((uploadStatus) {
//
//                     ///Update user notification id status == removed
//                     if(uploadStatus == UploadFirestoreResult.success){
//                       ///listen to firestore result, delete user, user quit group, user accept bike
//
//                       SmartDialog.dismiss(status: SmartStatus.loading);
//                       SmartDialog.show(
//                           keepSingle: true,
//                           widget: EvieSingleButtonDialogCupertino(
//                               title: "Success",
//                               content: "You deleted the user",
//                               rightContent: "Close",
//                               onPressedRight: () => SmartDialog.dismiss()
//                           ));
//                       currentSubscription?.cancel();
//                     } else if(uploadStatus == UploadFirestoreResult.failed) {
//                       SmartDialog.dismiss();
//                       SmartDialog.show(
//                           widget: EvieSingleButtonDialogCupertino(
//                               title: "Not success",
//                               content: "Try again",
//                               rightContent: "Close",
//                               onPressedRight: ()=>SmartDialog.dismiss()
//                           ));
//                     }
//
//                   },
//                   );
//
//                 },
//               ));
//         },
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//               borderRadius:
//               BorderRadius.circular(20.w)),
//           elevation: 0.0,
//           backgroundColor: EvieColors.primaryColor,
//
//         ),
//       ),
//     );
//   }
// }
