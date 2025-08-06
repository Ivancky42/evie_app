
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:provider/provider.dart';

import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/location_provider.dart';
import '../../../../widgets/action_list/deactivate_theft_alert.dart';

class ListOfAction extends StatefulWidget {
  List list;
  ListOfAction({
    required this.list,
    super.key,

  });

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
          await showDialog<void>(
              context: context,
              builder: (BuildContext context) =>
                  EvieDoubleButtonDialog(
                      title: "Close this sheet?",
                      childContent: Text("Are you sure you want to close this sheet?",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),),
                      leftContent: "No",
                      rightContent: "Yes",
                      onPressedLeft: () {
                        shouldClose = false;
                        Navigator.of(context).pop();
                      },
                      onPressedRight: () {
                        shouldClose = true;
                        Navigator.of(context).pop();
                      }));
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
