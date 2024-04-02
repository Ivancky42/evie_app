import 'package:evie_test/screen/my_bike_setting/about_bike/about_bike.dart';
import 'package:evie_test/screen/my_bike_setting/bike_status_alert/bike_status_alert.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/beta_firmware_information.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/firmware_information.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/firmware_update_completed.dart';
import 'package:evie_test/screen/my_bike_setting/firmware/firmware_update_failed.dart';
import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/detection_sensitivity.dart';
import 'package:evie_test/screen/my_bike_setting/motion_sensitivity/motion_sensitivity.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/create_team.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/invitation_sent.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/pedal_pals_list.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/pedal_pals.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/share_bike_invitation.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/user_not_found.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/bike_erase_leave.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/bike_erase_reset.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/bike_erase_unlink.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/forget_completed.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/full_completed.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/full_incomplete.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/full_reset.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/leave_successful.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/leave_team.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/leave_unsuccessful.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/reset_bike.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/reset_bike2.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/unlink_bike.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/restore_bike.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/restore_completed.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/restore_incomplete.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/forget_incomplete.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/ev_add_failed.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/ev_key.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/ev_key_list.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/name_ev.dart';
import 'package:evie_test/screen/my_bike_setting/rfid_card/register_ev_key.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/activateEVWithCode.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/add_plan.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/current_plan.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/current_plan_2.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/pro_plan/pro_plan.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/current_plan.dart';
import 'package:evie_test/screen/my_bike_setting/subscription/pro_plan/pro_plan2.dart';
import 'package:evie_test/screen/my_bike_setting/troubleshoot/troubleshoot.dart';
import 'package:evie_test/screen/my_bike_setting/user_manual/user_manual.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat/threat_history.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat/threat_map.dart';
import 'package:evie_test/widgets/evie_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting_container.dart';


import '../../api/colours.dart';
import '../../api/enumerate.dart';
import '../../api/navigator.dart';
import '../../api/provider/setting_provider.dart';
import '../user_home_page/paid_plan/map_detail.dart';
import '../user_home_page/paid_plan/threat/threat_history2.dart';
import 'bike_setting/bike_setting.dart';

class SheetNavigator extends StatefulWidget {

  final String source;
  final String stringPassing;
  final BuildContext? context;

   const SheetNavigator(
      this.source,
      this.stringPassing,
      {Key? key, this.context}) : super(key: key);

  @override
  State<SheetNavigator> createState() => _SheetNavigatorState();
}

class _SheetNavigatorState extends State<SheetNavigator> {

  late SettingProvider _settingProvider;

  @override
  Widget build(BuildContext context) {

    _settingProvider = Provider.of<SettingProvider>(context);

    //print(_settingProvider.currentSheetList);

    switch(_settingProvider.currentSheetList){
      case SheetList.mapDetails:
        return MapDetails();
      case SheetList.threatHistory:
        return ThreatHistory2();
      case SheetList.bikeSetting:
        return BikeSetting(source: widget.source);
      case SheetList.evKey:
        return EVKey();
      case SheetList.evKeyList:
        return EVKeyList();
      case SheetList.evAddFailed:
        return EVAddFailed();
      case SheetList.nameEv:
        return Container(
          height: double.infinity,
          //color: Colors.yellow,
          child: NameEV(),
        );
      case SheetList.registerEvKey:
        return RegisterEVKey();

      case SheetList.motionSensitivity:
        return MotionSensitivity();
      case SheetList.detectionSensitivity:
        return DetectionSensitivity();

      case SheetList.currentPlan:
        return CurrentPlan2();
      case SheetList.addPlan:
        return AddPlan();
      case SheetList.proPlan:
        return ProPlan2();
      case SheetList.activateEVWithCode:
        return ActivateEVWithCode(bContext: widget.context!,);

      case SheetList.pedalPals:
        return PedalPals();
      case SheetList.createTeam:
        return CreateTeam();
      case SheetList.shareBikeInvitation:
        return ShareBikeInvitation(totalSteps: int.parse(_settingProvider.stringPassing!),);
      case SheetList.invitationSent:
        return InvitationSent();
      case SheetList.userNotFound:
        return UserNotFound();
      case SheetList.pedalPalsList:
        return PedalPalsList(deviceIMEI: _settingProvider.stringPassing!,);

      case SheetList.orbitalAntiThefts:
        return BikeStatusAlert();

      case SheetList.aboutBike:
        return AboutBike();
      case SheetList.firmwareInformation:
        return FirmwareInformation();
      case SheetList.betaFirmwareInformation:
        return BetaFirmwareInformation();
      case SheetList.firmwareUpdateCompleted:
        return FirmwareUpdateCompleted();
      case SheetList.firmwareUpdateFailed:
        return FirmwareUpdateFailed();

      case SheetList.unlinkBike:
        return UnlinkBike();

      case SheetList.fullReset:
        return FullReset();

      case SheetList.userManual:
        return UserManual();
      case SheetList.troubleshoot:
        return TroubleshootScreen();
      case SheetList.resetBike:
        return ResetBike();
      case SheetList.resetBike2:
        return ResetBike2();
      case SheetList.restoreCompleted:
        return RestoreCompleted();
      case SheetList.restoreIncomplete:
        return RestoreIncomplete();

    case SheetList.forgetCompleted:
      return ForgetCompleted();
    case SheetList.forgetIncomplete:
      return ForgetIncomplete();
    case SheetList.fullCompleted:
      return FullCompleted();
    case SheetList.fullIncomplete:
      return FullIncomplete();

    case SheetList.bikeEraseUnlink:
    return BikeEraseUnlink();

      case SheetList.bikeEraseReset:
        return BikeEraseReset();

      case SheetList.leaveTeam:
        return LeaveTeam();

      case SheetList.bikeEraseLeave:
        return BikeEraseLeave();

      case SheetList.leaveSuccessful:
        return LeaveSuccessful();

      case SheetList.leaveUnsuccessful:
        return LeaveUnsuccessful();

      default:
        break;
    }
    return Container();
  }
}

