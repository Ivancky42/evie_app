import 'package:evie_bike/api/length.dart';
import 'package:evie_bike/api/sizer.dart';
import 'package:evie_bike/screen/my_bike_setting/bike_setting/bike_setting.dart';
import 'package:evie_bike/screen/my_bike_setting/pedal_pals/pedal_pals_list.dart';
//import 'package:evie_bike/screen/my_bike_setting/subscription2/pro_plan2/pro_plan2.dart';
//import 'package:evie_bike/screen/my_bike_setting/subscription2/current_plan2.dart';
//import 'package:evie_bike/screen/my_bike_setting/subscription2/essential_plan2/essential_plan2.dart';
//import 'package:evie_bike/screen/my_bike_setting/subscription2/manage_plan2.dart';
import 'package:evie_bike/screen/trip_history/recent_activity.dart';
import 'package:evie_bike/screen/trip_history/trip_history.dart';
import 'package:evie_bike/screen/user_home_page/battery_details.dart';
import 'package:evie_bike/screen/user_home_page/paid_plan/map_details.dart';
import 'package:evie_bike/screen/user_home_page/paid_plan/threat_history.dart';
import 'package:evie_bike/widgets/evie_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screen/my_bike_setting/bike_setting_navigator.dart';
import '../screen/my_bike_setting/bike_status_alert/bike_status_alert.dart';
import '../screen/my_bike_setting/pedal_pals/invitation_sent.dart';
import '../screen/my_bike_setting/pedal_pals/pedal_pals.dart';
import '../screen/my_bike_setting/pedal_pals/share_bike_invitation.dart';
import '../screen/my_bike_setting/pedal_pals/user_not_found.dart';

import '../screen/my_bike_setting/sheet_navigator.dart';
import '../screen/my_bike_setting/subscription/current_plan.dart';
import '../screen/my_bike_setting/subscription/essential_plan/essential_plan.dart';
import '../screen/my_bike_setting/subscription/pro_plan/pro_plan.dart';
import '../screen/trip_history/ride_history.dart';
import '../screen/user_home_page/paid_plan/map_details2.dart';
import '../screen/user_home_page/paid_plan/threat_timeline.dart';
//import '../../lib/api/enumerated.dart';

import 'model/trip_history_model.dart';


void showBikeSettingContentSheet(BuildContext context, [String? source, String? strings]) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: SheetNavigator(source ?? 'Home', strings ?? ''),);
    },
  );
}
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

void showPedalPalsSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const PedalPals(),);
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
      return EvieBottomSheet(childContext: BikeSetting(source ?? 'Home'));
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

void showCurrentPlanSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const CurrentPlan());
    },
  );
}

void showProPlanSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const ProPlan());
    },
  );
}

void showEssentialPlanSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    constraints: BoxConstraints.tight(Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * EvieLength.sheet_expand)),
    context: context,
    builder: (BuildContext context) {
      return EvieBottomSheet(childContext: const EssentialPlan());
    },
  );
}



         void showShareBikeUserListSheet(BuildContext context) {
           showModalBottomSheet(
             isScrollControlled: true,
              constraints: BoxConstraints.tight(Size(
                 MediaQuery
                     .of(context)
                     .size
                      .width,
                  MediaQuery
                     .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
              context: context,
              builder: (BuildContext context) {
                return EvieBottomSheet(childContext: const PedalPalsList());
              },
            );
          }

          void showShareBikeInvitationSheet(BuildContext context) {
            showModalBottomSheet(
              isScrollControlled: true,
              constraints: BoxConstraints.tight(Size(
                  MediaQuery
                      .of(context)
                      .size
                      .width,
                  MediaQuery
                      .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
              context: context,
              builder: (BuildContext context) {
                return EvieBottomSheet(
                    childContext: const ShareBikeInvitation());
              },
            );
          }

          void showUserNotFoundSheet(BuildContext context, String email) {
            showModalBottomSheet(
              isScrollControlled: true,
              constraints: BoxConstraints.tight(Size(
                  MediaQuery
                      .of(context)
                      .size
                      .width,
                  MediaQuery
                      .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
              context: context,
              builder: (BuildContext context) {
                return EvieBottomSheet(childContext: UserNotFound(email));
              },
            );
          }

          void showInvitationSentSheet(BuildContext context, String email) {
            showModalBottomSheet(
              isScrollControlled: true,
              constraints: BoxConstraints.tight(Size(
                  MediaQuery
                      .of(context)
                      .size
                      .width,
                  MediaQuery
                      .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
              context: context,
              builder: (BuildContext context) {
                return EvieBottomSheet(childContext: InvitationSent(email));
              },
            );
          }

          void showThreatHistorySheet(BuildContext context) {
            showModalBottomSheet(
              isScrollControlled: true,
              constraints: BoxConstraints.tight(Size(
                  MediaQuery
                      .of(context)
                      .size
                      .width,
                  MediaQuery
                      .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
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
                  MediaQuery
                      .of(context)
                      .size
                      .width,
                  MediaQuery
                      .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
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
                  MediaQuery
                      .of(context)
                      .size
                      .width,
                  MediaQuery
                      .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
              context: context,
              builder: (BuildContext context) {
                //return EvieBottomSheet(childContext: MapDetails(),);
                return EvieBottomSheet(childContext: MapDetails2(),);
              },
            );
          }

          void showRideHistorySheet(BuildContext context, String tripId,
              TripHistoryModel currentTripHistoryList) {
            showModalBottomSheet(
              isScrollControlled: true,
              constraints: BoxConstraints.tight(Size(
                  MediaQuery
                      .of(context)
                      .size
                      .width,
                  MediaQuery
                      .of(context)
                      .size
                      .height * EvieLength.sheet_expand)),
              context: context,
              builder: (BuildContext context) {
                return EvieBottomSheet(
                  childContext: RideHistory(tripId, currentTripHistoryList),);
              },
            );
          }




