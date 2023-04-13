import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../widgets/evie_card.dart';
import '../../home_page_widget.dart';


class Battery extends StatefulWidget {
  Battery({
    Key? key
  }) : super(key: key);

  @override
  State<Battery> createState() => _BatteryState();
}

class _BatteryState extends State<Battery> {

  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);

    return EvieCard(
      title: "Battery",
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(
              getBatteryImage(
                  _bikeProvider.currentBikeModel?.batteryPercent ?? 0),
              width: 36.w,
              height: 36.h,
            ),
            Text("${_bikeProvider.currentBikeModel?.batteryPercent ?? 0} %", style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray)),
            Text("Est 0km", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray),
            ),
            SizedBox(height: 16.h,),
          ],
        ),
      ),

    );
  }
}


