import 'package:evie_test/api/model/event_model.dart';
import 'package:evie_test/api/provider/bike_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/provider/location_provider.dart';

class OrbitalListContainer extends StatefulWidget {
  final EventModel eventModel;
  const OrbitalListContainer({Key? key, required this.eventModel}) : super(key: key);

  @override
  State<OrbitalListContainer> createState() => _OrbitalListContainerState();
}

class _OrbitalListContainerState extends State<OrbitalListContainer> {

  late LocationProvider _locationProvider;
  late BikeProvider _bikeProvider;
  String tempAddress = 'Loading';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _bikeProvider = Provider.of<BikeProvider>(context, listen: false);

    if (widget.eventModel.address == null) {
      fetchData();
    }
    else {
      tempAddress = widget.eventModel.address!;
    }
  }

  Future<String?> fetchData() async {
    String? address = await _locationProvider.returnPlaceMarksString(widget.eventModel.geopoint.latitude, widget.eventModel.geopoint.longitude);
    _bikeProvider.uploadPlaceMarkAddressToFirestore(
        _bikeProvider.currentBikeModel!.deviceIMEI!,
        widget.eventModel.eventId,
        address!
    );
    setState(() {
      tempAddress = address;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EventModel model = widget.eventModel;
    return Column(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
            //color: Colors.red,
            child:  Row(
              children: [
                SvgPicture.asset(
                  getSecurityIconWidget(model.type),
                  height: 36.w,
                  width: 36.w,
                ),
                SizedBox(width: 8.w,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tempAddress,
                      style: EvieTextStyles.body18,
                    ),
                    Text("${getSecurityTextWidget(
                        model.type)} • ${calculateTimeAgoWithTime(
                        model.created!)}",
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.darkGrayishCyan))
                  ],
                )
              ],
            ),
        ),
        Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.fromLTRB(40.w, 0, 0, 0),
              child: Divider(
                thickness: 0.5.h,
                color: EvieColors.lightGray,
                height: 0,
              ),
            )
        ),
      ],
    );
      ListTile(
        // minLeadingWidth : 10,
        // minVerticalPadding: 10,
        // horizontalTitleGap: 10,
        // visualDensity: VisualDensity(horizontal: 0, vertical: -4),
        leading: SvgPicture.asset(
          getSecurityIconWidget(model.type),
          height: 36.h,
          width: 36.w,
        ),
        title: Text(
            tempAddress,
          style: EvieTextStyles.body18,
        ),
        subtitle: Text("${getSecurityTextWidget(
            model.type)} • ${calculateTimeAgoWithTime(
            model.created!)}",
          style: EvieTextStyles.body14,)
    );
  }
}
