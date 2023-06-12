import 'package:evie_test/screen/my_bike_setting/about_bike/about_bike.dart';
import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/motion_sensitivity.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/create_team.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/invitation_sent.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/pedal_pals_list.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/pedal_pals.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/share_bike_invitation.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/user_not_found.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/ev_key.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/ev_key_list.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/current_plan.dart';
import 'package:evie_test/widgets/evie_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/enumerate.dart';
import '../../api/navigator.dart';
import '../../api/provider/setting_provider.dart';
import 'bike_setting/bike_setting.dart';

class BikeSettingNavigator extends StatefulWidget {

  final String source;
  final String stringPassing;

   const BikeSettingNavigator(
      this.source,
      this.stringPassing,
      {Key? key}) : super(key: key);

  @override
  State<BikeSettingNavigator> createState() => _BikeSettingNavigatorState();
}

class _BikeSettingNavigatorState extends State<BikeSettingNavigator> {

  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    switch(_settingProvider.currentSheetList){
      case SheetList.bikeSetting:
        return BikeSetting(widget.source);
      case SheetList.evKey:
        return EVKey();
      case SheetList.evKeyList:
        return EVKeyList();
      case SheetList.motionSensitivity:
        return MotionSensitivity();
      case SheetList.evCurrentSubscription:
        return CurrentPlan();
      case SheetList.evPlusSubscription:
        break;


      case SheetList.pedalPals:
        return PedalPals();
      case SheetList.createTeam:
        return CreateTeam();
      case SheetList.shareBikeInvitation:
        return ShareBikeInvitation();
      case SheetList.invitationSent:
        return InvitationSent(widget.stringPassing);
      case SheetList.userNotFound:
        return UserNotFound(widget.stringPassing);
      case SheetList.pedalPalsList:
        return PedalPalsList();


      case SheetList.orbitalAntiThefts:
        break;
      case SheetList.aboutBike:
        return AboutBike();
      case SheetList.bikeSoftware:
        break;
      case SheetList.userManual:
        break;
      case SheetList.reset:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
    return Container();
  }
}

