import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/screen/user_home_page/paid_plan/home_element/orbital_list_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/dialog.dart';
import '../../../../api/enumerate.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/model/event_model.dart';
import '../../../../api/model/location_model.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/current_user_provider.dart';
import '../../../../api/provider/setting_provider.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../../../widgets/evie_card_2.dart';

class LoadingMap extends StatefulWidget  {
  LoadingMap({
    Key? key
  }) : super(key: key);

  @override
  State<LoadingMap> createState() => _LoadingMapState();
}

class _LoadingMapState extends State<LoadingMap> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;
  late SettingProvider _settingProvider;

  int _currentIndex = 0;

  String title = 'Setting up \nyour bike';
  String label = "Hang on tight, \nwe're going for a \ndigital ride! \nBringing your bike \noutdoors may \nspeed this up.";

  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer?.cancel();
    timer = Timer(const Duration(seconds: 60), () {
      setState(() {
        title = "Let's try that \nagain";
        label = "It's taking longer \nthan usual. Try \nmoving your bike \noutdoors for a \nbetter connection.";
      });
    });
  }

  @override
  Future<void> dispose() async {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);
    _settingProvider = Provider.of<SettingProvider>(context);

    List<Widget> _widgets = [
      Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 23.w,),
            child: Container(
              //color: Colors.green,
              //height: 300.h,
              width: 150.w,
              child: Lottie.asset('assets/animations/loading-bike-status.json'),
            ),
          ),

          Padding(
              padding: EdgeInsets.only(bottom: 3.h, left:20.w, right: 16.w),
              child: Container(
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: EvieTextStyles.headlineB.copyWith(fontSize: 20.sp, height: 1.3),
                    ),
                    SizedBox(height: 4.h,),
                    Text(
                      label,
                      style: EvieTextStyles.body16.copyWith(height: 1.3),
                    )
                  ],
                ),
              )
          ),
        ],
      ),
      PaginateFirestore(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 16.w),
        itemsPerPage: 3,
        isLive: false,
        bottomLoader: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: 24),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: EvieColors.primaryColor,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (context, documentSnapshots, index) {
          // Check if there is data at the given index
          if (index < documentSnapshots.length) {
            DocumentSnapshot snapshot = documentSnapshots[index];
            Map<String, dynamic>? obj = snapshot.data() as Map<String, dynamic>?;
            if (obj != null) {
              EventModel eventModel = EventModel.fromJson(snapshot.id, obj);
              if (eventModel.type != 'lost') {
                return OrbitalListContainer(eventModel: eventModel);
              }
              else {
                return Container();
              }
            }
          }

          // Return a placeholder or an empty widget if there's no data to display
          return Container();
        },
        query: FirebaseFirestore.instance.collection("bikes")
            .doc(_bikeProvider.currentBikeModel?.deviceIMEI)
            .collection("events")
            .orderBy("created", descending: true),
      ),
    ];

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(
            color: EvieColors.transparent,
            width: 2.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF7A7A79).withOpacity(0.15), // Hex color with opacity
              offset: Offset(0, 8), // X and Y offset
              blurRadius: 16, // Blur radius
              spreadRadius: 0, // Spread radius
            ),
          ],
        ),
        child: Stack(
          children: [
            EvieCard2(
              onPress: (){},
              child: Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: CarouselSlider(
                            items: _widgets,
                            options: CarouselOptions(
                              padEnds: false,
                              height: double.infinity,
                              autoPlay: false,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                              aspectRatio: 16/9,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              viewportFraction: 1.0,
                            ),
                          ),
                        ),


                        Padding(
                          padding: EdgeInsets.only(bottom: 9.h, right:25.w, top: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _widgets.map((item) {
                              int index = _widgets.indexOf(item);
                              bool isCurrentIndex = _currentIndex == index;
                              //  double horizontalMargin = index == 0 ? 0.0 : 6.0;
                              double horizontalMargin = index == 0 ? 6.0 : 0.0;

                              return Container(
                                width: 6.w,
                                height: 6.h,
                                margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: horizontalMargin),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrentIndex ? EvieColors.primaryColor : EvieColors.progressBarGrey,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}


