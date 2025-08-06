import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:evie_test/api/toast.dart';
import 'package:evie_test/widgets/evie_appbar_badge.dart';
import 'package:evie_test/widgets/evie_divider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/enumerate.dart';
import '../../../api/function.dart';
import '../../../api/length.dart';
import '../../../api/model/bike_user_model.dart';
import '../../../api/model/user_model.dart';
import '../../../api/provider/current_user_provider.dart';
import '../../../api/provider/setting_provider.dart';
import '../../../api/sheet.dart';
import '../../../api/snackbar.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_textform.dart';


///User profile page with user account information

class PedalPalsList extends StatefulWidget {
  final String deviceIMEI;
  const PedalPalsList({super.key, required this.deviceIMEI});

  @override
  _PedalPalsListState createState() => _PedalPalsListState();
}

class _PedalPalsListState extends State<PedalPalsList> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late CurrentUserProvider _currentUserProvider;
  late StreamSubscription deleteRFIDStream;
  late SettingProvider _settingProvider;

  bool isManageList = false;
  bool isOwner = false;

  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bikeProvider = context.read<BikeProvider>();
    switchBike(widget.deviceIMEI);
  }

  Future switchBike(String deviceIMEI) async {
    await _bikeProvider.changeBikeUsingIMEI(deviceIMEI);
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);
    isOwner = _bikeProvider.isOwner!;

    return WillPopScope(
      onWillPop: () async {
        //_settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Scaffold(
        appBar: PageAppbarWithBadge(
          title: 'PedalPals',
          withAction: isOwner ? _bikeProvider.bikeUserList.length != 1 ? true : false : false,
          //withAction: isOwner  ? true : false ,
          onPressedLeading: () {
            _settingProvider.changeSheetElement(SheetList.bikeSetting);
          },
          onPressedAction: () {
            showActionListSheet(context, [ActionList.removeAllPals],);
          },
        ),
        body: Container(
          //color: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.h, 14.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          _bikeProvider.currentBikeModel?.pedalPalsModel?.name ?? "None",
                          style: EvieTextStyles.h3,
                        ),

                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){

                            FocusNode nameFocusNode = FocusNode();
                            nameFocusNode.requestFocus();

                            bool isFirst = true;

                            _nameController.text = _bikeProvider.currentBikeModel?.pedalPalsModel?.name ?? '';

                            _nameController.addListener(() {
                              if (_nameController.selection.baseOffset != _nameController.selection.extentOffset) {
                                // Text is selected
                                //print('Text selected: ${_nameController.text.substring(_nameController.selection.baseOffset, _nameController.selection.extentOffset)}');
                              } else {
                                // Cursor is moved
                                if (isFirst) {
                                  isFirst = false;
                                  _nameController.selection = TextSelection(
                                      baseOffset: 0, extentOffset: _nameController.text.length);
                                }
                              }
                            });

                            SmartDialog.show(
                                builder: (_) => Form(
                                  key: _formKey,
                                  child: EvieDoubleButtonDialog(
                                      title: "Team Name",
                                      childContent: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Give your team an epic name", style: TextStyle(fontSize: 16.sp, color: Color(0xff252526)),),
                                            Padding(
                                              padding:  EdgeInsets.fromLTRB(0.h, 12.h, 0.h, 8.h),
                                              child: EvieTextFormField(
                                                controller: _nameController,
                                                obscureText: false,
                                                keyboardType: TextInputType.name,
                                                hintText: "Create an epic team name",
                                                labelText: "Team Name",
                                                focusNode: nameFocusNode,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter your name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      leftContent: "Cancel",
                                      rightContent: "Save",
                                      onPressedLeft: (){SmartDialog.dismiss();},
                                      onPressedRight: () async {
                                        if (_formKey.currentState!.validate()) {
                                          SmartDialog.dismiss();
                                          final result = await _bikeProvider.updateTeamName(_nameController.text.trim());

                                          result == true ?
                                          showTeamNameUpdated(context)
                                              :
                                          showTeamNameUpdateFailed(context);
                                        }
                                      }),
                                ));
                          },
                          child: SvgPicture.asset(
                            "assets/buttons/pen_edit.svg",
                            height: 31.h,
                            width: 31.w,
                          ),
                        ),
                      ],
                    ),
                  ),

                  EvieDivider( thickness: 0.5,color: Color(0xFF8E8E8E),),

                  _bikeProvider.bikeUserList.length == 1 ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 32.h),
                        child: Text(
                          "Invite up to 4 riders to share your EVIE bike. PedalPals get access to unlocking, anti-theft features, notifications, and trip history.",
                          style: EvieTextStyles.body18,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(45.w, 0.h, 45.2.w,22.h),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/images/share_bike.svg",
                            height: 287.89.h,
                            width: 262.07.w,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 47.h, 16.w,0.h),
                          child: Text(
                            "No pal is currently sharing your bike.",
                            style: TextStyle(fontSize: 16.sp,height: 1.5.h),
                          ),
                        ),
                      ),
                    ],
                  ) :
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.w, 3.h, 0.w, 4.h),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(left: 84.w),
                          child: Divider(height: 1.h),
                        );
                      },
                      itemCount: _bikeProvider.bikeUserList.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                          enabled: isOwner && _bikeProvider.bikeUserList.keys.elementAt(index) != _currentUserProvider.currentUserModel!.uid,
                          endActionPane:  ActionPane(
                            extentRatio: 0.18,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                spacing:10,
                                onPressed: (context) async {
                                  final result = await showDeleteShareBikeUser( _bikeProvider.bikeUserList.values.elementAt(index), checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails), _bikeProvider.currentBikeModel!.pedalPalsModel!);
                                  Map<String, dynamic> jsonData = json.decode(result);
                                  // Accessing individual fields
                                  String uid = jsonData['uid'];
                                  String name = jsonData['name'];
                                  String teamName = jsonData['teamName'];
                                  String status = jsonData['status'];
                                  String notificationId = jsonData['notificationId'];
                                  String resulted = jsonData['result'];

                                  if (resulted == "action") {
                                    //SmartDialog.showLoading(msg:"Removing " + name + " ....");
                                    showCustomLightLoading("Removing $name ....");
                                    StreamSubscription? currentSubscription;
                                    ///Cancel user invitation
                                    if(status == "pending"){
                                      print(notificationId);
                                      if (notificationId != '') {
                                        currentSubscription = _bikeProvider.cancelSharedBike(
                                            uid,
                                            notificationId).listen((uploadStatus) {

                                          if(uploadStatus == UploadFirestoreResult.success){
                                            SmartDialog.dismiss(status: SmartStatus.loading);
                                            showTextToast(name + " have been removed from " + teamName + '.');
                                            currentSubscription?.cancel();
                                          }
                                          else if(uploadStatus == UploadFirestoreResult.failed) {
                                            SmartDialog.dismiss();
                                            currentSubscription?.cancel();
                                            SmartDialog.show(
                                                builder: (_) => EvieSingleButtonDialogOld(
                                                    title: "Not success",
                                                    content: "Try again",
                                                    rightContent: "Close",
                                                    onPressedRight: ()=>SmartDialog.dismiss()
                                                ));

                                          }
                                        },);
                                      }
                                      else {
                                        Future.delayed(Duration(seconds: 3)).then((value) {
                                          SmartDialog.dismiss();
                                          currentSubscription?.cancel();
                                          SmartDialog.show(
                                              builder: (_) => EvieSingleButtonDialogOld(
                                                  title: "Unable to remove user",
                                                  content: "Please try again later",
                                                  rightContent: "Close",
                                                  onPressedRight: ()=>SmartDialog.dismiss()
                                              ));
                                        });
                                      }
                                    }
                                    else{
                                      ///Remove user
                                      currentSubscription = _bikeProvider.removedSharedBike(
                                          uid,
                                          notificationId).listen((uploadStatus) {

                                        if(uploadStatus == UploadFirestoreResult.success){
                                          SmartDialog.dismiss(status: SmartStatus.loading);
                                          showTextToast(name + " have been removed from " + teamName + '.');
                                          currentSubscription?.cancel();
                                        }
                                        else if(uploadStatus == UploadFirestoreResult.failed) {
                                          SmartDialog.dismiss();
                                          currentSubscription?.cancel();
                                          SmartDialog.show(
                                              builder: (_) => EvieSingleButtonDialogOld(
                                                  title: "Not success",
                                                  content: "Try again",
                                                  rightContent: "Close",
                                                  onPressedRight: ()=>SmartDialog.dismiss()
                                              ));
                                        }
                                      },
                                      );
                                    }
                                  }
                                  //showRemoveUserToast(context, result);
                                },
                                backgroundColor: EvieColors.lightRed,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                              ),
                            ],
                          ),
                          child: ListTile(
                            ///Put user profile image here
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                  //imageUrl: document['profileIMG'],
                                  imageUrl: checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails) != null ? checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails)!.profileIMG : '',
                                  placeholder: (context, url) =>
                                  const CircularProgressIndicator(color: EvieColors.primaryColor,),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              title: Row(
                                children: [
                                  Text(
                                      checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails) != null ? checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails)!.name! : '',
                                      style: EvieTextStyles.body18),

                                  Visibility(
                                    visible: _currentUserProvider.currentUserModel!.name == (checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails) != null ? checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails)!.name! : ''),
                                    child: Text(
                                        " (You)",
                                        style: EvieTextStyles.body18.copyWith(color: EvieColors.darkGrayishCyan)),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                  checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails) != null ? checkUid(_bikeProvider.bikeUserList.values.elementAt(index), _bikeProvider.bikeUserDetails)!.email : '',
                                  style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayish)),

                              trailing: isOwner == true && isManageList && _bikeProvider.bikeUserList.keys.elementAt(index) == _currentUserProvider.currentUserModel!.uid ?
                              Text(checkUserAndChangeText(_bikeProvider.bikeUserList.values.elementAt(index).role),
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayish),)
                                  : isManageList ?
                              Container()
                              //            ShareBikeDelete(bikeProvider: _bikeProvider, index: index,)
                                  : isOwner == false && _bikeProvider.bikeUserList.keys.elementAt(index) == _currentUserProvider.currentUserModel!.uid ?
                              ShareBikeLeave(bikeProvider: _bikeProvider, settingProvider: _settingProvider, index: index,)
                                  : _bikeProvider.bikeUserList.values.elementAt(index).status == "pending" ?
                              SvgPicture.asset(
                                "assets/icons/pending_tag.svg",
                              )
                                  : Text(checkUserAndChangeText(_bikeProvider.bikeUserList.values.elementAt(index).role),
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayish),),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Visibility(
                    visible: isOwner,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, EvieLength.target_reference_button_a),
                        child: EvieButton(
                          width: double.infinity,
                          height: 48.h,
                          backgroundColor: _bikeProvider.bikeUserList.length < 5 ? EvieColors.primaryColor : EvieColors.primaryColor.withOpacity(0.3),
                          onPressed: () {
                            ///Check if bike already have 5 user
                            if(_bikeProvider.bikeUserList.length < 5 ){
                              _settingProvider.changeSheetElement(SheetList.shareBikeInvitation, '2');
                            }else{
                              showExceedLimit(context);
                            }
                          },
                          child: Text(
                              "Invite PedalPal",
                              style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                          )
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }

  UserModel? checkUid(BikeUserModel bikeUserModel, LinkedHashMap<dynamic, dynamic> bikeUserDetails) {
    String uidToCheck = bikeUserModel.uid;

    String? keyContainingUid;
    for (var entry in bikeUserDetails.entries) {
      if (entry.key == uidToCheck) {
        keyContainingUid = entry.key;
        break; // Exit the loop once the key is found
      }
    }

    if (keyContainingUid != null) {
      return bikeUserDetails[keyContainingUid];
    }
    else {
      return null;
    }
  }

}
