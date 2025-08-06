
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../api/toast.dart';

class RemoveAllPals extends StatefulWidget {
  const RemoveAllPals({
    super.key,

  });

  @override
  State<RemoveAllPals> createState() => _RemoveAllPalsState();
}

class _RemoveAllPalsState extends State<RemoveAllPals> {

  late BikeProvider _bikeProvider;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    return Padding(
      padding:
      EdgeInsets.only(left: 0.w, top: 0.h, bottom: 0.h, right: 0.w),
      child: GestureDetector(
          onTap: () async {
            Navigator.pop(context);
            final result = await showRemoveAllPals(context, _bikeProvider.currentBikeModel?.pedalPalsModel?.name ?? "None");
            if (result == "action") {
              showCustomLightLoading("Removing all Pedal Pals...");
              final result = await _bikeProvider.removeAllPedalPals();
              if (result == 'Success') {
                showTextToast("Successfully removed all the PedalPals from your team.");
                SmartDialog.dismiss(status: SmartStatus.loading);
              }
            }
          },
          child: Container(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 8.w, right: 8.w),
              leading: Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                ),
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/delete_black.svg",
                    ),
                  ),
                ),
              ),
              title:Text(
                "Remove All PedalPals",
                style: EvieTextStyles.body18.copyWith(fontWeight: FontWeight.bold, color: EvieColors.mediumLightBlack),
              ),
              subtitle: Wrap(
                  children: [
                    Text(
                      "Delete all the PedalPals from your team.",
                      style: EvieTextStyles.body14.copyWith(fontWeight: FontWeight.bold, color: EvieColors.darkGrayishCyan),
                    ),
                  ]
              ),
            ),
          )
      ),
    );
  }
}
