import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/provider/location_provider.dart';
import 'package:evie_test/api/sheet.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../api/colours.dart';
import '../../../../api/fonts.dart';
import '../../../../api/function.dart';
import '../../../../api/model/location_model.dart';
import '../../../../api/provider/bike_provider.dart';
import '../../../../api/provider/bluetooth_provider.dart';
import '../../../../api/provider/notification_provider.dart';
import '../../../../bluetooth/modelResult.dart';
import '../../../../widgets/evie_card.dart';
import '../../add_new_bike/mapbox_widget.dart';
import 'package:latlong2/latlong.dart';

import '../../home_page_widget.dart';

class OrbitalAntiTheft extends StatefulWidget {


  OrbitalAntiTheft({
    Key? key
  }) : super(key: key);

  @override
  State<OrbitalAntiTheft> createState() => _OrbitalAntiTheftState();
}

class _OrbitalAntiTheftState extends State<OrbitalAntiTheft> with SingleTickerProviderStateMixin {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;
  late LocationProvider _locationProvider;

  GeoPoint? selectedGeopoint;
  DeviceConnectResult? deviceConnectResult;

  MapController? mapController;

  var markers = <Marker>[];

  late AnimationController _animationController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    selectedGeopoint  = _locationProvider.locationModel?.geopoint;
    mapController = MapController();

    // _animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 3000));
    // _animationController..addStatusListener((status) {
    //   if(status == AnimationStatus.completed) _animationController.forward(from: 0);
    // });
    // _animationController.addListener(() {
    //   setState(() {
    //   });
    // });
    // _animationController.repeat(max: 1);
    // _animationController.forward();
  }

  @override
  void dispose() {
    mapController?.dispose();
    // _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);
    _locationProvider = Provider.of<LocationProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    loadMarker();

    List<Widget> _widgets = [
      Row(
        children: [
          FutureBuilder(
              future: getLocationModel(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: SizedBox(
                      width: 176.w,
                      child: Mapbox_Widget(
                        isInteract: false,
                        accessToken: _locationProvider.defPublicAccessToken,
                        //onMapCreated: _onMapCreated,
                        mapController: mapController,
                        markers: markers,
                        // onUserLocationUpdate: (userLocation) {
                        //   if (this.userLocation != null) {
                        //     this.userLocation = userLocation;
                        //     getDistanceBetween();
                        //   }
                        //   else {
                        //     this.userLocation = userLocation;
                        //     getDistanceBetween();
                        //     runSymbol();
                        //   }
                        // },
                        latitude: _locationProvider.locationModel!.geopoint.latitude,
                        longitude: _locationProvider.locationModel!.geopoint.longitude,
                        zoom: 15,
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),

          // Selector<BikeProvider, int>(
          //   selector: (context, bikeProvider) => bikeProvider.currentBikeList,
          //   builder: (context, myValue, child) {
          //     return Text('My Value: $myValue');
          //   },
          // ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(getCurrentBikeStatusIcon(_bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),),
                  Text(getCurrentBikeStatusString(deviceConnectResult == DeviceConnectResult.connected, _bikeProvider.currentBikeModel!, _bikeProvider, _bluetoothProvider),
                    style: EvieTextStyles.headlineB.copyWith(color: EvieColors.darkGray),),

                  selectedGeopoint != null
                      ? FutureBuilder<dynamic>(
                      future: _locationProvider.returnPlaceMarks(selectedGeopoint!.latitude, selectedGeopoint!.longitude),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data.name.toString(),
                            style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                          );
                        }else{
                          return Text(
                            "loading",
                            style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),
                          );
                        }
                      }
                  )
                      : Text(_locationProvider.currentPlaceMark?.name ?? "Not available",style: EvieTextStyles.body18.copyWith( color: EvieColors.mediumLightBlack),),

                  ///Bike provider lastUpdated minus current timestamp
                  Text(calculateTimeAgo(_bikeProvider.currentBikeModel!.lastUpdated!.toDate()),
                      style: EvieTextStyles.body14.copyWith(color: EvieColors.mediumLightBlack)),
                ],
              ),
            ),
          ),
        ],
      ),

      PaginateFirestore(
          itemBuilderType: PaginateBuilderType.listView,
          itemBuilder: (context, documentSnapshots, index) {
            final data = documentSnapshots[index].data() as Map?;
            if(_bikeProvider.threatFilterArray.contains(data!['type'])) {
              return Column(
                children: [
                  ListTile(
                      leading: data == null ? const Text('Error')
                          : SvgPicture.asset(
                        getSecurityIconWidget(data['type']),
                        height: 36.h,
                        width: 36.w,
                      ),
                      title: data == null ? const Text('Error')
                          : data["address"] != null
                          ? Text(data["address"], style: EvieTextStyles.body18,)
                          : FutureBuilder<dynamic>(
                          future: _locationProvider.returnPlaceMarks(
                              data["geopoint"].latitude,
                              data["geopoint"].longitude),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _bikeProvider.uploadPlaceMarkAddressToFirestore(
                                  _bikeProvider.currentBikeModel!.deviceIMEI!,
                                  documentSnapshots[index].id, snapshot.data
                                  .name.toString());
                              return Text(
                                snapshot.data.name.toString(),
                                style: EvieTextStyles.body18,
                              );
                            } else {
                              return const Text(
                                "loading",
                              );
                            }
                          }
                      ),
                      subtitle: data == null
                          ? const Text('Error in data')
                          : Text("${getSecurityTextWidget(
                          data["type"])} • ${calculateTimeAgoWithTime(
                          data["created"]!.toDate())}",
                        style: EvieTextStyles.body12,)

                  ),
                  const Divider(height: 1),
                ],
              );
            }else{
              return Container();
            }

          },
          query: FirebaseFirestore.instance.collection("bikes")
              .doc(_bikeProvider.currentBikeModel!.deviceIMEI!)
              .collection("events")
          //.where('type', whereIn: ['lock'])
          //.where('type', whereIn: _bikeProvider.threatFilterArray)
              .orderBy("created", descending: true),
          itemsPerPage: 3,
          isLive: false,
          ),
    ];

    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          // gradient: SweepGradient(
          //     startAngle: 0,
          //     colors: [Colors.white,EvieColors.lightRed,Colors.white,EvieColors.lightRed],
          //     transform: GradientRotation(_animationController.value*6)
          // )
      ),
      child: EvieCard(
        onPress: (){
          if(_currentIndex == 0){
            showMapDetailsSheet(context);
          }else{
            showThreatHistorySheet(context);
          }
        },
        height: 285.h,
        title: "Orbital Anti-theft",
        child: Expanded(
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  items: _widgets,
                  options: CarouselOptions(
                    padEnds: false,

                    height: double.infinity,
                    //height: 323.h,
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
                padding:  EdgeInsets.only(top: 9.h, bottom: 9.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _widgets.map((item) {
                    int index = _widgets.indexOf(item);
                    return Container(
                      width: 6.w,
                      height: 6.h,
                      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? EvieColors.primaryColor : EvieColors.progressBarGrey,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<LocationModel?> getLocationModel() async {
    return _locationProvider.locationModel;
  }

  void loadMarker() {

    markers = <Marker>[

      if(_locationProvider.locationModel!.isConnected == true && _bikeProvider.currentBikeModel?.location?.status == "danger")...{
        ///load a few more marker
        for(int i = 0; i < _bikeProvider.threatRoutesLists.length; i++)...{
          Marker(
            width: 30.w,
            height: 40.h,
            point: LatLng(_bikeProvider.threatRoutesLists.values
                .elementAt(i)
                .geopoint
                .latitude ?? 0,
                _bikeProvider.threatRoutesLists.values
                    .elementAt(i)
                    .geopoint
                    .longitude ?? 0),
            builder: (ctx) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  selectedGeopoint = _bikeProvider.threatRoutesLists.values
                      .elementAt(i)
                      .geopoint;
                });
              },
              child: _bikeProvider.threatRoutesLists.values.elementAt(i).geopoint == selectedGeopoint ?
              SvgPicture.asset("assets/icons/marker_danger.svg",)
                  : SvgPicture.asset("assets/icons/marker_danger_deactive.svg",),
            ),
          ),
        },

        Marker(
          width: 42.w,
          height: 56.h,
          point: LatLng(_locationProvider.locationModel?.geopoint.latitude ?? 0,
              _locationProvider.locationModel?.geopoint.longitude ?? 0),
          builder: (ctx) =>
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    selectedGeopoint = _locationProvider.locationModel?.geopoint;
                  });
                },
                child: _locationProvider.locationModel?.geopoint == selectedGeopoint ?
                SvgPicture.asset(
                  "assets/icons/marker_danger.svg",
                  height: 56.h,
                )
                    : SvgPicture.asset(
                  "assets/icons/marker_danger_deactive.svg",
                  height: 56.h,
                ),
              ),
        ),

      }else...{

        Marker(
          width: 42.w,
          height: 56.h,
          point: LatLng(_locationProvider.locationModel?.geopoint.latitude ?? 0,
              _locationProvider.locationModel?.geopoint.longitude ?? 0),
          builder: (ctx) => Image(
            image: AssetImage(!_locationProvider.locationModel!.isConnected ? "assets/icons/marker_warning.png" : loadMarkerImageString(_locationProvider.locationModel?.status ?? "")),
          ),
        ),
      },

      ///User marker
      // Marker(
      //   width: 42.w,
      //   height: 56.h,
      //   point: currentLatLng,
      //   builder: (ctx) {
      //     return _buildCompass();
      //   },
      // ),
    ];
  }

  void animateBounce() {
    // if (_locationProvider.locationModel != null && userLocation != null) {
    //
    //   final LatLng southwest = LatLng(
    //     min(_locationProvider.locationModel!.geopoint.latitude,
    //         userLocation!.latitude!),
    //     min(_locationProvider.locationModel!.geopoint.longitude,
    //         userLocation!.longitude!),
    //   );
    //
    //   final LatLng northeast = LatLng(
    //     max(_locationProvider.locationModel!.geopoint.latitude,
    //         userLocation!.latitude!),
    //     max(_locationProvider.locationModel!.geopoint.longitude,
    //         userLocation!.longitude!),
    //   );
    //
    //   latLngBounds = LatLngBounds(southwest, northeast);
    //
    //   if (currentScroll <= (initialRatio) && currentScroll > minRatio + 0.01) {
    //     mapController?.fitBounds(latLngBounds,
    //         options: FitBoundsOptions(
    //           padding: EdgeInsets.fromLTRB(170.w, 100.h, 170.w, 360.h),
    //         ));
    //   } else if (currentScroll >= minRatio) {
    //     mapController?.fitBounds(latLngBounds,
    //         options: FitBoundsOptions(
    //           padding: EdgeInsets.fromLTRB(80.w, 80.h, 80.w, 120.h),
    //         ));
    //   }
    // }
  }
}


