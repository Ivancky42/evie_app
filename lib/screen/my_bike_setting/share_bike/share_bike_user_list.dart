import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/screen/my_bike_setting/share_bike/share_bike_function.dart';


import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/dialog.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/current_user_provider.dart';
import '../../../theme/ThemeChangeNotifier.dart';
import '../../../widgets/evie_appbar.dart';
import '../../../widgets/evie_single_button_dialog.dart';


///User profile page with user account information

class ShareBikeUserList extends StatefulWidget {
  const ShareBikeUserList({Key? key}) : super(key: key);

  @override
  _ShareBikeUserListState createState() => _ShareBikeUserListState();
}

class _ShareBikeUserListState extends State<ShareBikeUserList> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late CurrentUserProvider _currentUserProvider;
  late StreamSubscription deleteRFIDStream;

  bool isManageList = false;
  bool isOwner = false;

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);

    isOwner = _bikeProvider.isOwner!;

    return WillPopScope(
      onWillPop: () async {
        changeToNavigatePlanScreen(context);
        return false;
      },
      child: Scaffold(
        appBar: PageAppbar(
          title: 'Share Bike',
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
                  padding: EdgeInsets.fromLTRB(0.w, 28.h, 0.w, 4.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) {
                      return Divider(height: 1.h);
                    },
                    itemCount: _bikeProvider.bikeUserList.length,
                    itemBuilder: (context, index) {
                        return Slidable(
                          enabled: isOwner && _bikeProvider.bikeUserList.keys.elementAt(index) != _currentUserProvider.currentUserModel!.uid,
                          endActionPane:  ActionPane(
                            extentRatio: 0.3,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                spacing:10,
                                onPressed: (context){
                                  showDeleteShareBikeUser(_bikeProvider, index);
                                },
                                backgroundColor: EvieColors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: ListTile(
                            ///Put user profile image here
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                  //imageUrl: document['profileIMG'],
                                  imageUrl: _bikeProvider.bikeUserDetails.values.elementAt(index).profileIMG,
                                  placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              title: Text(
                                  _bikeProvider.bikeUserDetails.values.elementAt(index).name,
                                style: EvieTextStyles.body18),
                              subtitle: Text(
                                "${_bikeProvider.bikeUserDetails.values.elementAt(index).email}",
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayish)),

                            trailing: isOwner == true && isManageList && _bikeProvider.bikeUserList.keys.elementAt(index) == _currentUserProvider.currentUserModel!.uid ?
                            Text(_bikeProvider.bikeUserList.values.elementAt(index).role,
                                style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayish),)
                                : isManageList ?
                                Container()
                          //            ShareBikeDelete(bikeProvider: _bikeProvider, index: index,)
                                : isOwner == false && _bikeProvider.bikeUserList.keys.elementAt(index) == _currentUserProvider.currentUserModel!.uid ?
                                      ShareBikeLeave(bikeProvider: _bikeProvider, index: index,)
                                : _bikeProvider.bikeUserList.values.elementAt(index).status == "pending" ?
                            SvgPicture.asset(
                              "assets/icons/pending_tag.svg",
                            )
                                : Text(_bikeProvider.bikeUserList.values.elementAt(index).role,
                              style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayish),)
                          ),
                        );
                    },
                  ),
                ),
              ],
            ),



            ///Bottom page button
            isManageList ? Visibility(
              visible: isOwner,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 127.84.h, 16.w,
                      EvieLength.buttonWord_ButtonBottom),
                  child: EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Save",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
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
                : Visibility(
                visible: isOwner,
                  child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 127.84.h, 16.w,
                      EvieLength.buttonWord_ButtonBottom),
                  child: EvieButton(
                    width: double.infinity,
                    height: 48.h,
                    child: Text(
                      "Add Rider",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite)
                    ),
                    onPressed: () {
                      ///Check if bike already have 5 user
                      if(_bikeProvider.bikeUserList.length <= 5 ){
                        changeToShareBikeScreen(context);
                      }else{
                        SmartDialog.show(widget: EvieSingleButtonDialog(
                            title: "Exist Limit",
                            content: "Only 5 user are allowed",
                            rightContent: "OK",
                            onPressedRight: (){SmartDialog.dismiss();}));
                              }
                            },
                          ),
                      ),
                    ),
                ),


            ///Bottom page button
            isManageList ? Visibility(
             visible: isOwner,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 52.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: EvieButton_ReversedColor(
                      width: double.infinity,
                      height: 52.h,
                      child: Text(
                        "Cancel",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)
                      ),
                      onPressed: () {
                        setState(() {
                          isManageList = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            )
                :
            Visibility(
              visible: isOwner,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 52.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: EvieButton_ReversedColor(
                      width: double.infinity,
                      height: 52.h,
                      child: Text(
                        "Remove All Rider",
                          style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.primaryColor)
                      ),
                      onPressed: () {

                      },
                    ),
                  ),
                ),
              ),
            ),
                /*
            Visibility(
              visible: isOwner,
                  child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 52.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: EvieButton_ReversedColor(
                      width: double.infinity,
                      height: 52.h,
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
                ),
            */
          ],
        ),
      ),
    );
  }

}
