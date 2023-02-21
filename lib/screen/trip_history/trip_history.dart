import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:evie_test/api/backend/sim_api_caller.dart';
import 'package:evie_test/api/colours.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/bluetooth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/bluetooth/modelResult.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../api/fonts.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({Key? key}) : super(key: key);

  @override
  _TripHistoryState createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 51.h, 0.w, 7.h),
                child: Container(
                  child: Text(
                    "Trip History",
                    style: EvieTextStyles.h1.copyWith(color: EvieColors.mediumBlack),
                  ),
                ),
              ),


           GestureDetector(
             onTap: (){
               changeToTestBLEScreen(context);
             },
               child: Center(child: Text("You do not have permission to view this page")))
              
            ],
          )
      ),
    );
  }
}
