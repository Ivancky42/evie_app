import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/my_bike_setting/bike_setting/bike_setting_model.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/sheet.dart';
import '../../../bluetooth/modelResult.dart';

class BikeSettingSearchContainer extends StatefulWidget {
  final String searchResult;
  final String currentSearchString;
  final BikeSettingModel bikeSettingModel;
  const BikeSettingSearchContainer({Key? key, required this.bikeSettingModel, required this.searchResult, required this.currentSearchString}) : super(key: key);

  @override
  State<BikeSettingSearchContainer> createState() => _BikeSettingSearchContainerState();
}

class _BikeSettingSearchContainerState extends State<BikeSettingSearchContainer> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  DeviceConnectResult? deviceConnectResult;

  String? label;
  String? pageNavigate;

  @override
  Widget build(BuildContext context) {
    label = widget.bikeSettingModel.label;
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    switch(label) {
      case "Bike Status Alert":
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                showBikeStatusAlertSheet(context);
              },
              child: Container(
                height: 62.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: searchMatch(widget.searchResult),
                          ),
                          Text(
                            label!,
                            style:EvieTextStyles.body18.copyWith( color: EvieColors.darkGrayishCyan,),
                          )
                        ],
                      ),
                      SvgPicture.asset(
                        "assets/buttons/next.svg",
                        height: 24.h,
                        width: 24.w,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const EvieDivider(),
          ],
        );
      // case "SOS Center":
      //   return Column(
      //     children: [
      //       GestureDetector(
      //         behavior: HitTestBehavior.translucent,
      //         onTap: () {
      //           changeToSOSCenterScreen(context);
      //         },
      //         child: Container(
      //           height: 62.h,
      //           child: Padding(
      //             padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: [
      //                     RichText(
      //                       text: searchMatch(widget.searchResult),
      //                     ),
      //                     Text(
      //                       label!,
      //                       style:EvieTextStyles.body18.copyWith( color: EvieColors.darkGrayishCyan,),
      //
      //                     )
      //                   ],
      //                 ),
      //                 SvgPicture.asset(
      //                   "assets/buttons/next.svg",
      //                   height: 24.h,
      //                   width: 24.w,
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       const EvieDivider(),
      //     ],
      //   );
      default:
        return Container(
          child: const Center(
            child: Text("APA LU MAU"),
          ),
        );
    }
  }

  TextSpan searchMatch(String match) {
    var refinedMatch = match.toLowerCase();
    var refinedSearch = widget.currentSearchString.toLowerCase();
    if (refinedMatch.contains(refinedSearch)) {
      if (refinedMatch.substring(0, refinedSearch.length) == refinedSearch) {
        return TextSpan(
          style: EvieTextStyles.body16.copyWith(color: EvieColors.primaryColor),

          text: match.substring(0, refinedSearch.length),
          children: [
            searchMatch(
              match.substring(
                refinedSearch.length,
              ),
            ),
          ],
        );
      } else if (refinedMatch.length == refinedSearch.length) {
        return TextSpan(text: match, style: EvieTextStyles.body16.copyWith(color: EvieColors.primaryColor),
        );
      } else {
        return TextSpan(
          style: EvieTextStyles.body16.copyWith(color: Colors.black),
          text: match.substring(
            0,
            refinedMatch.indexOf(refinedSearch),
          ),
          children: [
            searchMatch(
              match.substring(
                refinedMatch.indexOf(refinedSearch),
              ),
            ),
          ],
        );
      }
    } else if (!refinedMatch.contains(refinedSearch)) {
      return TextSpan(text: match,style: EvieTextStyles.body16.copyWith(color: Colors.black),
      );
    }
    return TextSpan(
      text: match.substring(0, refinedMatch.indexOf(refinedSearch)),
      style: EvieTextStyles.body16.copyWith(color: Colors.black),

      children: [
        searchMatch(match.substring(refinedMatch.indexOf(refinedSearch)))
      ],
    );
  }
}
