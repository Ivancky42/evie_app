import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/bike_container.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/navigator.dart';
import '../../api/provider/bike_provider.dart';

class SwitchBike extends StatefulWidget {
  const SwitchBike({Key? key}) : super(key: key);

  @override
  State<SwitchBike> createState() => _SwitchBikeState();
}

class _SwitchBikeState extends State<SwitchBike> {

  @override
  Widget build(BuildContext context) {
    BikeProvider _bikeProvider = Provider.of<BikeProvider>(context);

    return Wrap(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFECEDEB),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Column(
            children: [
              /// home indicator
              Padding(
                padding: EdgeInsets.only(top: 11.h, bottom: 11.h),
                child: Image.asset(
                  "assets/buttons/home_indicator.png",
                  width: 40.w,
                  height: 4.h,
                ),
              ),

              /// bike list
              ListView.builder(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bikeProvider.userBikeDetails.length,
                itemBuilder: (context, index) {

                  return BikeContainer(bikeModel: _bikeProvider.userBikeDetails.values.elementAt(index));
                },
              ),

              ///Add new bike
              Padding(
                padding:  EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 39.h),
                child: EvieButton(
                    onPressed: (){
                      _bikeProvider.setIsAddBike(true);
                      changeToStayCloseToBike(context);
                    },
                    child: Text(
                      "Add More Bike",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}


