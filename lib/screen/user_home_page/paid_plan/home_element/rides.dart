import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/provider/ride_provider.dart';
import '../../../../api/sheet.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_oval.dart';

class Rides extends StatefulWidget {

  Rides({

    Key? key
  }) : super(key: key);

  @override
  State<Rides> createState() => _RidesState();
}

class _RidesState extends State<Rides> {

  late RideProvider _rideProvider;

  @override
  void initState() {
    super.initState();
    _rideProvider = context.read<RideProvider>();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rideProvider = Provider.of<RideProvider>(context);
    return EvieCard(
      title: "Rides",
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top:12.h),
              child: EvieOvalGray(
                buttonText: _rideProvider.weekCardDataTypeString!,
                onPressed: () {
                  if(_rideProvider.weekCardDateType == RideDataType.mileage){
                    _rideProvider.setWeekData(RideDataType.noOfRide);
                  }
                  else if(_rideProvider.weekCardDateType == RideDataType.noOfRide){
                    _rideProvider.setWeekData(RideDataType.carbonFootprint);
                  }
                  else if(_rideProvider.weekCardDateType == RideDataType.carbonFootprint){
                    _rideProvider.setWeekData(RideDataType.mileage);
                  }
                },),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(_rideProvider.weekCardData ?? '-', style: EvieTextStyles.display,),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(_rideProvider.weekCardDataUnit ?? '', style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray,)),
                      )
                    ],
                  ),
                  Text("this week", style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGray,height: 1.2),),
                  SizedBox(height: 16.h,),
                ],
              ),
            ),
          ],
        ),
      ),
      onPress: (){
        showTripHistorySheet(context);
      },
    );
  }
}


