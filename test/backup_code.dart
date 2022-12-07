// FittedBox(
//                                                                 child:
//                                                                 FloatingActionButton(
//                                                                   elevation: 0,
//                                                                   backgroundColor:
//                                                                   cableLockState
//                                                                       ?.lockState ==
//                                                                       LockState
//                                                                           .lock
//                                                                       ? lockColour
//                                                                       : const Color(
//                                                                       0xffC1B7E8),
//                                                                   onPressed: cableLockState
//                                                                       ?.lockState ==
//                                                                       LockState.lock
//                                                                       ? () {
//                                                                     ///Check is connected
//
//                                                                     SmartDialog
//                                                                         .showLoading(
//                                                                         msg:
//                                                                         "Unlocking");
//                                                                     StreamSubscription?
//                                                                     subscription;
//                                                                     subscription =
//                                                                         _bluetoothProvider
//                                                                             .cableUnlock()
//                                                                             .listen(
//                                                                                 (unlockResult) {
//                                                                               SmartDialog.dismiss(
//                                                                                   status: SmartStatus
//                                                                                       .loading);
//                                                                               subscription
//                                                                                   ?.cancel();
//                                                                               if (unlockResult
//                                                                                   .result ==
//                                                                                   CommandResult
//                                                                                       .success) {
//                                                                                 ScaffoldMessenger.of(
//                                                                                     context)
//                                                                                     .showSnackBar(
//                                                                                   const SnackBar(
//                                                                                     content:
//                                                                                     Text('Bike is unlocked. To lock bike......'),
//                                                                                     duration:
//                                                                                     Duration(seconds: 2),
//                                                                                   ),
//                                                                                 );
//                                                                               } else {
//                                                                                 SmartDialog.dismiss(
//                                                                                     status:
//                                                                                     SmartStatus.loading);
//                                                                                 subscription
//                                                                                     ?.cancel();
//                                                                                 ScaffoldMessenger.of(
//                                                                                     context)
//                                                                                     .showSnackBar(
//                                                                                   SnackBar(
//                                                                                     width:
//                                                                                     90.w,
//                                                                                     behavior:
//                                                                                     SnackBarBehavior.floating,
//                                                                                     shape: const RoundedRectangleBorder(
//                                                                                         borderRadius:
//                                                                                         BorderRadius.all(Radius.circular(10))),
//                                                                                     content:
//                                                                                     Container(
//                                                                                       height:
//                                                                                       9.h,
//                                                                                       child:
//                                                                                       Column(
//                                                                                         children: [
//                                                                                           const Align(
//                                                                                             alignment: Alignment.topLeft,
//                                                                                             child: Text('Bike is unlocked. To lock bike......'),
//                                                                                           ),
//                                                                                           Align(
//                                                                                             alignment: Alignment.centerRight,
//                                                                                             child: TextButton(
//                                                                                               child: const Text(
//                                                                                                 'LEARN MORE',
//                                                                                                 style: TextStyle(color: Color(0xff836ED3)),
//                                                                                               ),
//                                                                                               onPressed: () {},
//                                                                                             ),
//                                                                                           ),
//                                                                                         ],
//                                                                                       ),
//                                                                                     ),
//                                                                                     duration:
//                                                                                     const Duration(seconds: 4),
//                                                                                   ),
//                                                                                 );
//                                                                               }
//                                                                             }, onError: (error) {
//                                                                           SmartDialog.dismiss(
//                                                                               status: SmartStatus
//                                                                                   .loading);
//                                                                           subscription
//                                                                               ?.cancel();
//                                                                           SmartDialog.show(
//                                                                               widget: EvieSingleButtonDialogCupertino(
//                                                                                   title: "Error",
//                                                                                   content: "Cannot unlock bike, please place the phone near the bike and try again.",
//                                                                                   rightContent: "OK",
//                                                                                   onPressedRight: () {
//                                                                                     SmartDialog.dismiss();
//                                                                                   }));
//                                                                         });
//                                                                   }
//                                                                       : null,
//                                                                   //icon inside button
//                                                                   child: lockImage,
//                                                                 ),),