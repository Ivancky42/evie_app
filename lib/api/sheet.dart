import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting.dart';
import 'package:evie_test/screen/trip_history/recent_activity.dart';
import 'package:evie_test/screen/trip_history/trip_history.dart';
import 'package:evie_test/screen/user_home_page/battery_details.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/map_details.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat_history.dart';
import 'package:evie_test/widgets/evie_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screen/my_bike_setting/bike_status_alert/bike_status_alert.dart';
import '../screen/my_bike_setting/share_bike/share_bike.dart';
import '../screen/my_bike_setting/share_bike/share_bike_user_list.dart';
import '../screen/trip_history/ride_history.dart';
import '../screen/user_home_page/paid_plan/map_details2.dart';
import '../screen/user_home_page/paid_plan/threat_timeline.dart';
import 'model/trip_history_model.dart';

void showTripHistorySheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const TripHistory(),);
    },
  );
}

void showBikeSettingSheet(BuildContext context, [String? source]) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: BikeSetting(source ?? 'Home'),);
    },
  );
}

void showBikeStatusAlertSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const BikeStatusAlert());
    },
  );
}

void showShareBikeSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const ShareBike());
    },
  );
}

void showShareBikeUserListSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const ShareBikeUserList());
    },
  );
}


void showThreatHistorySheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: ThreatHistory(),);
    },
  );
}

void showBatteryDetailsSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: BatteryDetails(),);
    },
  );
}

void showMapDetailsSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      //return EvieBottomSheet(childContext: MapDetails(),);
      return EvieBottomSheet(childContext: MapDetails2(),);
    },
  );
}

void showRideHistorySheet(BuildContext context,String tripId, TripHistoryModel currentTripHistoryList) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: RideHistory(tripId, currentTripHistoryList),);
    },
  );
}
