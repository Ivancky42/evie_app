
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting.dart';
import 'package:evie_test/screen/my_bike_setting/pedal_pals/pedal_pals_list.dart';
import 'package:evie_test/screen/my_bike_setting/reset_bike/bike_erase.dart';
import 'package:evie_test/screen/ride/ride_detail.dart';
import 'package:evie_test/screen/trip_history/trip_history.dart';
import 'package:evie_test/screen/user_home_page/battery_details.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat_history.dart';
import 'package:evie_test/widgets/evie_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../screen/my_bike_setting/bike_status_alert/bike_status_alert.dart';
import '../screen/my_bike_setting/pedal_pals/pedal_pals.dart';
import '../screen/my_bike_setting/pedal_pals/share_bike_invitation.dart';
import '../screen/my_bike_setting/reset_bike/leave_successful.dart';
import '../screen/my_bike_setting/reset_bike/leave_team.dart';
import '../screen/my_bike_setting/reset_bike/leave_unsuccessful.dart';
import '../screen/my_bike_setting/sheet_navigator.dart';
import '../screen/my_bike_setting/subscription/current_plan.dart';
import '../screen/my_bike_setting/subscription/pro_plan/pro_plan.dart';
import '../screen/ride/ride_history.dart';
import '../screen/user_home_page/paid_plan/map_detail.dart';
import 'enumerate.dart';
import 'model/trip_history_model.dart';

void showSheetNavigate(BuildContext context, [String? source, String? strings]) {
  showCupertinoSheet(context, SheetNavigator(source ?? 'Home', strings ?? ''));
}

void showTripHistorySheet(BuildContext context) {
  showCupertinoSheet(context, const RideHistory());
}

void showBikeEraseSheet(BuildContext context) {
  showCupertinoSheet(context, const BikeErase());
}

void showLeaveTeamSheet(BuildContext context) {
  showCupertinoSheet(context, const LeaveTeam());
}

void showLeaveSuccessfulSheet(BuildContext context) {
  showCupertinoSheet(context, const LeaveSuccessful());
}

void showLeaveUnsuccessfulSheet(BuildContext context) {
  showCupertinoSheet(context, const LeaveUnsuccessful());
}



void showPedalPalsSheet(BuildContext context) {
  showCupertinoSheet(context, const PedalPals());
}

void showBikeSettingSheet(BuildContext context, [String? source]) {
  showCupertinoSheet(context, BikeSetting(source: source ?? 'Home'));
}

void showBikeStatusAlertSheet(BuildContext context) {
  showCupertinoSheet(context, const BikeStatusAlert());
}

// void showCurrentPlanSheet(BuildContext context) {
//   showCupertinoSheet(context, const CurrentPlan());
// }

void showProPlanSheet(BuildContext context) {
  showCupertinoSheet(context, const ProPlan());
}

// void showEssentialPlanSheet(BuildContext context) {
//   showCupertinoSheet(context, const EssentialPlan());
// }

void showShareBikeUserListSheet(BuildContext context) {
  showCupertinoSheet(context, const PedalPalsList());
}

void showShareBikeInvitationSheet(BuildContext context) {
  showCupertinoSheet(context, const ShareBikeInvitation());
}

void showThreatHistorySheet(BuildContext context) {
  showCupertinoSheet(context, ThreatHistory());
}

void showBatteryDetailsSheet(BuildContext context) {
  // Navigator.of(context).push(
  //   CupertinoModalBottomSheetRoute<void>(
  //     expanded: true,
  //     builder: (BuildContext context) =>
  //     BatteryDetails(),
  //   ),
  // );
   showCupertinoSheet(context, BatteryDetails());
}

void showMapDetailsSheet(BuildContext context) {
  showCupertinoSheet(context, MapDetails());
}

void showRideHistorySheet(BuildContext context, String tripId, TripHistoryModel currentTripHistoryList) {
  showCupertinoSheet(context, RideDetail(tripId, currentTripHistoryList));
}

void showCupertinoSheet(BuildContext context, Widget widget) {
  // Navigator.of(context).push(
  //   CupertinoSheetRoute<void>(
  //     builder: (BuildContext context) => EvieBottomSheet(widget: widget,),
  //   ),
  // );
  showCupertinoModalBottomSheet(
    expand: true,
    useRootNavigator: true,
    ///enableDrag: false,
    ///isDismissible: false,
    context: context,
    builder: (context) => EvieBottomSheet(widget: widget,),
  );
}

void showActionListSheet(BuildContext context, List<ActionList> action) {
  // Navigator.of(context).push(
  //   CupertinoSheetRoute<void>(
  //     builder: (BuildContext context) => EvieBottomSheet(widget: widget,),
  //   ),
  // );
  showCupertinoModalBottomSheet(
    expand: false,
    useRootNavigator: true,
    ///enableDrag: false,
    ///isDismissible: false,
    context: context,
    builder: (context) => Wrap(
        children: [
          EvieBottomSheetAction(lists: action)
        ]
    ),
  );
}