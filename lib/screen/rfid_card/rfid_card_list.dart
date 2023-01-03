import 'dart:async';

import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import '../../bluetooth/modelResult.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_textform.dart';
import '../user_home_page/user_home_page.dart';

///User profile page with user account information

class RFIDCardList extends StatefulWidget {
  const RFIDCardList({Key? key}) : super(key: key);

  @override
  _RFIDCardListState createState() => _RFIDCardListState();
}

class _RFIDCardListState extends State<RFIDCardList> {
  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  bool isManageList = false;

  late StreamSubscription deleteRFIDStream;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    final TextEditingController _rfidNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: AccountPageAppbar(
          title: 'RFID Card',
          onPressed: () {
            changeToNavigatePlanScreen(context);
          },
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 4.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) {
                      return Divider(height: 1.h);
                    },
                    itemCount: _bikeProvider.rfidList.length,
                    itemBuilder: (context, index) {
                   if(_bikeProvider.rfidList.length > 0) {
                   return ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: Padding(
                       padding: EdgeInsets.fromLTRB(0.w, 0.h, 6.w, 0.h),
                       child: SvgPicture.asset(
                         "assets/icons/person.svg",
                         height: 30.h,
                         width: 30.w,
                       ),
                     ),
                     title: Text(
                       _bikeProvider.rfidList.values.elementAt(index).rfidName,
                       style: TextStyle(fontSize: 16.sp),
                     ),
                     subtitle: Text(
                       _bikeProvider.rfidList.keys.elementAt(index),
                       style: TextStyle(fontSize: 12.sp, color: Color(0xff5F6060)),
                     ),
                     trailing: isManageList ? Container(
                       width: 107.w,
                       height: 43.h,
                       child: ElevatedButton(
                         child: Row(
                           mainAxisAlignment:
                           MainAxisAlignment.center,
                           children: [
                             SvgPicture.asset(
                               "assets/icons/delete.svg",
                               height: 20.h,
                               width: 20.w,
                             ),
                             Text(
                               "Delete",
                               style: TextStyle(
                                   fontSize: 12.sp,
                                   color: Color(0xffECEDEB)),
                             ),
                           ],
                         ),
                         onPressed: () {
                           SmartDialog.showLoading(msg: "Delete RFID....");
                           deleteRFIDStream = _bluetoothProvider
                               .deleteRFID(_bikeProvider
                               .rfidList.keys
                               .elementAt(index))
                               .listen((deleteRFIDStatus) {

                             SmartDialog.dismiss(status: SmartStatus.loading);

                             if (deleteRFIDStatus.result == CommandResult.success) {
                               deleteRFIDStream.cancel();
                               final result = _bikeProvider.deleteRFIDFirestore(
                                   _bikeProvider.rfidList.keys
                                       .elementAt(index));
                               if (result) {
                                 SmartDialog.dismiss(
                                     status: SmartStatus.loading);
                                 SmartDialog.show(
                                     widget:
                                     EvieSingleButtonDialog(
                                         title: "Deleted",
                                         content:
                                         "RFID card deleted",
                                         rightContent: "OK",
                                         onPressedRight: () {
                                           SmartDialog
                                               .dismiss();
                                           setState(() { isManageList = true; });
                                         }));
                               } else {
                                 SmartDialog.show(
                                     widget:
                                     EvieSingleButtonDialog(
                                         title:
                                         "Error deleting rfid",
                                         content:
                                         "Error deleting rfid",
                                         rightContent: "OK",
                                         onPressedRight: () {
                                           SmartDialog
                                               .dismiss();
                                         }));
                               }
                             }
                           }, onError: (error) {
                             deleteRFIDStream.cancel();
                             SmartDialog.dismiss(
                                 status: SmartStatus.loading);
                             SmartDialog.show(
                                 widget: EvieSingleButtonDialog(
                                     title: "Error deleting rfid",
                                     content: error.toString(),
                                     rightContent: "OK",
                                     onPressedRight: () {
                                       SmartDialog.dismiss();
                                     }));
                           });
                         },
                         style: ElevatedButton.styleFrom(
                           shape: RoundedRectangleBorder(
                               borderRadius:
                               BorderRadius.circular(20.w)),
                           elevation: 0.0,
                           backgroundColor: EvieColors.PrimaryColor,
                           padding: EdgeInsets.symmetric(
                               horizontal: 14.h, vertical: 14.h),
                         ),
                       ),
                     )
                         : IconButton(
                       onPressed: () {
                         SmartDialog.show(
                             widget: Form(
                               key: _formKey,
                               child: EvieDoubleButtonDialog(
                                   title: "Name Your RFID Card",
                                   childContent: Container(
                                     child: Column(
                                       crossAxisAlignment:
                                       CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           "Give your RFID Card a unique name.",
                                           style: TextStyle(
                                               fontSize: 16.sp,
                                               color: Color(0xff252526)),
                                         ),
                                         Padding(
                                           padding: EdgeInsets.fromLTRB(
                                               0.h, 12.h, 0.h, 8.h),
                                           child: EvieTextFormField(
                                             controller:
                                             _rfidNameController,
                                             obscureText: false,
                                             keyboardType: TextInputType.name,
                                             hintText:
                                             "give your RFID card a unique name",
                                             labelText: "RFID Card Name",
                                             validator: (value) {
                                               if (value == null || value.isEmpty) {
                                                 return 'Please enter RFID name';
                                               }
                                               return null;
                                             },
                                           ),
                                         ),
                                         Text(
                                           "100 Maximum Character",
                                           style: TextStyle(
                                               fontSize: 12.sp,
                                               color: Color(0xff252526)),
                                         ),
                                       ],
                                     ),
                                   ),
                                   leftContent: "Cancel",
                                   rightContent: "Save",
                                   onPressedLeft: () {
                                     SmartDialog.dismiss();
                                   },
                                   onPressedRight: () async {
                                     if (_formKey.currentState!.validate()) {
                                       SmartDialog.dismiss();
                                       final result = await _bikeProvider.updateRFIDCardName(
                                           _bikeProvider.rfidList.keys.elementAt(index),
                                           _rfidNameController.text.trim());

                                       result == true ? SmartDialog.show(
                                           widget:
                                           EvieSingleButtonDialog(
                                               title: "Success",
                                               content:
                                               "Name uploaded",
                                               rightContent:
                                               "OK",
                                               onPressedRight:
                                                   () {
                                                 SmartDialog
                                                     .dismiss();
                                               }))
                                           : SmartDialog.show(
                                           widget:
                                           EvieSingleButtonDialog(
                                               title: "Error",
                                               content:
                                               "Please try again",
                                               rightContent:
                                               "OK",
                                               onPressedRight:
                                                   () {
                                                 SmartDialog
                                                     .dismiss();
                                               }));
                                     }
                                   }),
                             ));
                       },
                       icon: SvgPicture.asset(
                         "assets/buttons/pen_edit.svg",
                         height: 24.h,
                         width: 24.w,
                       ),
                     ),
                   );
                   }else{
                   return Container();
                   }
                    },
                  ),
                ),
              ],
            ),



            ///Bottom page button
            isManageList ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 127.84.h, 16.w,
                          EvieLength.buttonWord_ButtonBottom),
                      child: EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                          "Save",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          setState(() {
                            isManageList = false;
                          });
                        },
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 127.84.h, 16.w,
                          EvieLength.buttonWord_ButtonBottom),
                      child: EvieButton(
                        width: double.infinity,
                        height: 48.h,
                        child: Text(
                          "Add RFID Card",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          changeToAddNewRFIDScreen(context);
                        },
                      ),
                    ),
                  ),


            ///Bottom page button
            isManageList ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 56.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: EvieColors.PrimaryColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            setState(() {
                              isManageList = false;
                            });
                          },
                        ),
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 48.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: EvieButton_ReversedColor(
                          width: double.infinity,
                          height: 48.h,
                          child: Text(
                            "Manage List",
                            style: TextStyle(
                                color: EvieColors.PrimaryColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            setState(() {
                              isManageList = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
