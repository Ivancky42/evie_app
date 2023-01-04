import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_account/my_account_widget.dart';
import 'package:evie_test/screen/share_bike/share_bike_function.dart';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';
import '../../api/provider/current_user_provider.dart';
import '../../bluetooth/modelResult.dart';
import '../../theme/ThemeChangeNotifier.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../../widgets/evie_textform.dart';
import '../user_home_page/user_home_page.dart';

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
        appBar: AccountPageAppbar(
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
                        return ListTile(
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
                                _bikeProvider.bikeUserDetails.values.elementAt(index).name, style: TextStyle(fontSize: 16.sp),),

                            subtitle: Text(
                              "${_bikeProvider.bikeUserDetails.values.elementAt(index).email}",
                              style: TextStyle(fontSize:12.sp, color: ThemeChangeNotifier().isDarkMode(context)
                                  == true ? Colors.white70: Colors.black54,),
                          ),

                          trailing: isOwner == true && isManageList && _bikeProvider.bikeUserList.keys.elementAt(index) == _currentUserProvider.currentUserModel!.uid ?
                          Text(_bikeProvider.bikeUserList.values.elementAt(index).role,
                              style: TextStyle(fontSize: 12.sp, color: Color(0xff7A7A79)))
                              : isManageList ?
                                    ShareBikeDelete(bikeProvider: _bikeProvider, index: index,)
                              : isOwner == false && _bikeProvider.bikeUserList.keys.elementAt(index) == _currentUserProvider.currentUserModel!.uid ?
                                    ShareBikeLeave(bikeProvider: _bikeProvider, index: index,)
                              : _bikeProvider.bikeUserList.values.elementAt(index).status == "pending" ?
                          SvgPicture.asset(
                            "assets/icons/pending_tag.svg",
                          )
                              : Text(_bikeProvider.bikeUserList.values.elementAt(index).role,
                              style: TextStyle(fontSize: 12.sp, color: Color(0xff7A7A79)))
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
                      "Add \"Sharee\"?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700),
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
              ),
            )
                : Visibility(
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
          ],
        ),
      ),
    );
  }

}
