
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/fonts.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_divider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/length.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../api/provider/notification_provider.dart';
import '../../api/snackbar.dart';

class RemoveAllPals extends StatefulWidget {
  RemoveAllPals({
    Key? key,

  }) : super(key: key);

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
              SmartDialog.showLoading(msg: "Removing all Pedal Pals...");
              final result = await _bikeProvider.removeAllPedalPals();
              if (result == 'Success') {
                showRemoveUserToast(context, "Successfully removed all the PedalPals from your team.");
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
                child: Container(
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
