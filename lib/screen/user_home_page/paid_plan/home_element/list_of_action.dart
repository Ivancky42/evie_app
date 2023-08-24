
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
import '../../../../widgets/action_list/deactivate_theft_alert.dart';

class ListOfAction extends StatefulWidget {
  List list;
  ListOfAction({
    required this.list,
    Key? key,

  }) : super(key: key);

  @override
  State<ListOfAction> createState() => _ListOfActionState();
}

class _ListOfActionState extends State<ListOfAction> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;

  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();
  int? snapshotLength;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    return Material(
      child: WillPopScope(
        onWillPop: () async {
          bool shouldClose = true;
          await showCupertinoDialog<void>(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text('Close Sheet?'),
                actions: <Widget>[
                  CupertinoButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      shouldClose = true;
                      Navigator.of(context).pop();
                    },

                  ),
                  CupertinoButton(
                    child: const Text('No'),
                    onPressed: () {
                      shouldClose = false;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
          return shouldClose;
        },

        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [

              DeactivateTheftAlert(),

          ],
        ),
      ),
    );
  }
}
