import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../bluetooth/modelResult.dart';


///Double button dialog
class HomePageWidget_ChangeBikeBottomSheet extends StatelessWidget{
  String currentDangerState;
  String? lastSeen;
  Placemark? location;
  String? minutesAgo;


  HomePageWidget_ChangeBikeBottomSheet({
    Key? key,
    required this.currentDangerState,
    this.lastSeen,
    this.location,
    this.minutesAgo,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
      return false;
    }, child: ModalBottomSheet(
        animationController: animationController,
        scrollController: scrollController,
        expanded: expanded,
        onClosing: onClosing,
        child: Container(
          width: double.infinity,
          height: 100.h,
          child: Column(
            children: [

            ],
          ),

        ))

    );

  }
}

