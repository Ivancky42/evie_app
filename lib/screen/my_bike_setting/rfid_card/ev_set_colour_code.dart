// import 'dart:io';
// import 'package:evie_test/api/provider/auth_provider.dart';
// import 'package:evie_test/api/provider/bluetooth_provider.dart';
// import 'package:evie_test/api/sizer.dart';
// import 'package:evie_test/screen/my_account/my_account_widget.dart';
// import 'package:evie_test/widgets/evie_dropdown.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:evie_test/widgets/evie_double_button_dialog.dart';
// import 'package:evie_test/widgets/evie_button.dart';
//
// import '../../../api/length.dart';
// import '../../../api/navigator.dart';
// import '../../../api/provider/bike_provider.dart';
// import '../../../widgets/evie_appbar.dart';
// import '../../../widgets/evie_single_button_dialog.dart';
// import '../../../widgets/evie_textform.dart';
//
//
//
// class EVColourCode extends StatefulWidget {
//   final String rfidNumber;
//
//   const EVColourCode(this.rfidNumber, {Key? key}) : super(key: key);
//
//   @override
//   _EVColourCodeState createState() => _EVColourCodeState();
// }
//
// class _EVColourCodeState extends State<EVColourCode> {
//   final _formKey = GlobalKey<FormState>();
//   late BikeProvider _bikeProvider;
//   late BluetoothProvider _bluetoothProvider;
//   String? selectedColour;
//
//   @override
//   Widget build(BuildContext context) {
//     _bikeProvider = Provider.of<BikeProvider>(context);
//     _bluetoothProvider = Provider.of<BluetoothProvider>(context);
//
//
//     return WillPopScope(
//       onWillPop: () async {
//
//         return false;
//       },
//       child: Scaffold(
//         appBar: PageAppbar(
//           title: 'New EV-Key',
//           onPressed: () {
//            changeToMyAccount(context);
//           },
//         ),
//         body: Stack(
//           children: [
//             Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 4.h),
//                     child: Text(
//                       "Color code your EV-Key",
//                       style: TextStyle(
//                           fontSize: 24.sp, fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 15.h),
//                     child: Text(
//                       "Personalize your EV-Keys by labeling them with different colors. Get organized and have fun with color coding.",
//                       style: TextStyle(fontSize: 16.sp, height: 1.5.h),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
//                     child: EvieDropdown(
//                       validator: (value) {
//                         if (value == null) {
//                           return 'Please select colour';
//                         }
//                         return null;
//                       },
//                       hintText: 'Color Tag',
//                       value: selectedColour,
//                       listItems:  ['Black','Grey','Purple','Blue','Green','Yellow','Red'].map((item) => DropdownMenuItem<String>(
//                         value: item,
//                         child: Row(
//                           children: [
//                             SvgPicture.asset(
//                               "assets/icons/eclipse_${item.toLowerCase()}.svg",
//                             ),
//                             SizedBox(width: 8.w,),
//                             Text(
//                               item,
//                               style: const TextStyle(fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )).toList(),
//
//                     onChanged: (value){
//                         setState(() {
//                           selectedColour = value.toString();
//                         });
//                     },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(
//                     16.w, 127.84.h, 16.w, EvieLength.button_Bottom),
//                 child: SizedBox(
//                   height: 48.h,
//                   width: double.infinity,
//                   child: EvieButton(
//                     width: double.infinity,
//                     child: Text(
//                       "Save",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w700),
//                     ),
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         print("choose colour is ${selectedColour}");
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void addRFIDtoFireStore(String rfidName) async {
//     final result = await _bikeProvider.uploadRFIDtoFireStore(widget.rfidNumber, rfidName);
//     if (result == true) {
//       SmartDialog.show(
//           widget: EvieSingleButtonDialog(
//               title: "Success",
//               content: "Card added",
//               rightContent: "OK",
//               onPressedRight: () {
//                 SmartDialog.dismiss();
//
//                 ///Change to rfid list
//                 changeToEVKeyList(context);
//               }));
//     } else {
//       SmartDialog.show(
//           widget: EvieSingleButtonDialog(
//               title: "Error",
//               content: "Error upload rfid to firestore",
//               rightContent: "OK",
//               onPressedRight: () {
//                 SmartDialog.dismiss();
//                 changeToEVKey(context);
//               }));
//     }
//   }
// }
