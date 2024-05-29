import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/colours.dart';
import '../../../api/enumerate.dart';
import '../../../api/length.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../widgets/evie_progress_indicator.dart';
import '../../../widgets/evie_textform.dart';
import '../../my_account/my_account_widget.dart';


class CreateTeam extends StatefulWidget{
  const CreateTeam({ Key? key }) : super(key: key);
  @override
  _CreateTeamState createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;
  late SettingProvider _settingProvider;

  final TextEditingController _teamNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    return WillPopScope(
      onWillPop: () async {
      //_settingProvider.changeSheetElement(SheetList.bikeSetting);
        return true;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 21.h),
                  child: EvieProgressIndicator(currentPageNumber: 0, totalSteps: 3,),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 21.h, 16.w, 4.h),
                  child: Text(
                    "Name your team",
                    style: EvieTextStyles.h2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 15.h),
                  child: Text(
                    "Create an epic name for your team.",
                    style: EvieTextStyles.body18,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                  child: EvieTextFormField(
                    controller: _teamNameController,
                    obscureText: false,
                    focusNode: _focusNode,
                    hintText: "Create an epic team name",
                    labelText: "Team Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a team name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 120.h, 16.w, 0),
                  child: EvieButton(
                      width: double.infinity,
                      height: 48.h,
                      child: Text(
                        "Create Team",
                        style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _bikeProvider.createTeam(_teamNameController.text.trim()).then((result) {
                            if(result == true){
                              _settingProvider.changeSheetElement(SheetList.shareBikeInvitation, '3');
                            }else{
                              SmartDialog.show(
                                  backDismiss: false,
                                  widget: EvieSingleButtonDialog(
                                      title: "Failed to create team",
                                      content: "Please try again.",
                                      rightContent: "Retry",
                                      onPressedRight: () {
                                        SmartDialog.dismiss();
                                      }
                                  ));
                            }
                          });
                        }
                      }
                  )
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(0, 15.h,0,EvieLength.target_reference_button_b),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Can't think of any name now",
                      softWrap: false,
                      style: EvieTextStyles.body18_underline,
                    ),
                    onPressed: () {
                      _bikeProvider.createTeam("Team ${_currentUserProvider.currentUserModel!.name}").then((result) {
                        if(result == true){
                          _settingProvider.changeSheetElement(SheetList.shareBikeInvitation, '3');
                        }else{
                          SmartDialog.show(
                              backDismiss: false,
                              widget: EvieSingleButtonDialog(
                                  title: "Failed to create team",
                                  content: "Please try again.",
                                  rightContent: "Retry",
                                  onPressedRight: () {
                                    SmartDialog.dismiss();
                                  }
                              ));
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

}