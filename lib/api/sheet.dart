import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting.dart';
import 'package:evie_test/screen/trip_history/trip_history.dart';
import 'package:evie_test/widgets/evie_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showTripHistorySheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * .90)),
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
        MediaQuery.of(context).size.height * .90)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const BikeSetting("Home"),);
    },
  );
}