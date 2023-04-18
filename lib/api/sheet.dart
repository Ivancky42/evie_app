import 'package:evie_test/api/length.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting.dart';
import 'package:evie_test/screen/trip_history/trip_history.dart';
import 'package:evie_test/screen/user_home_page/battery_details.dart';
import 'package:evie_test/screen/user_home_page/map_details.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/threat_history.dart';
import 'package:evie_test/widgets/evie_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

void showBikeSettingSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const BikeSetting("Home"),);
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
      return EvieBottomSheet(childContext: MapDetails(),);
    },
  );
}
