import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:evie_test/api/function.dart';
import 'package:sizer/sizer.dart';

import 'package:evie_test/widgets/custom_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../api/backend/debouncer.dart';
import '../../../api/colours.dart';
import '../../../api/fonts.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../api/snackbar.dart';
import '../../../bluetooth/modelResult.dart';
import 'bike_setting_container.dart';
import 'bike_setting_model.dart';
import 'bike_setting_search_container.dart';
import 'package:lottie/lottie.dart' as lottie;


class BikeSetting extends StatefulWidget {
  String? source;
  BikeSetting({this.source, super.key});

  @override
  _BikeSettingState createState() => _BikeSettingState();
}

class _BikeSettingState extends State<BikeSetting> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  DeviceConnectResult? deviceConnectResult;
  StreamController? connectStream;

  Widget? buttonImage;
  List<BikeSettingModel> bikeSettingList = [];
  final List<BikeSettingModel> _searchFirstResult = [];
  final LinkedHashMap<String, BikeSettingModel> _searchSecondResult = LinkedHashMap<String, BikeSettingModel>();

  bool _isSearching = false;
  bool isFirstTimeConnected = false;

  final searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  late Future loadDataFuture;
  late ScaffoldMessengerState _navigator;

  Future<List<BikeSettingModel>> loadData() async {
    var data = json.decode(await rootBundle.loadString("assets/files/bike_settings.json"));
    bikeSettingList.clear();
    for (var element in (data as List)) {
      bikeSettingList.add(BikeSettingModel.fromJson(element));
    }
    return bikeSettingList;
  }

  @override
  void initState() {
    super.initState();
    loadDataFuture = loadData();
  }

  @override
  void didChangeDependencies() {
    _navigator = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    hideCurrentSnackBar(_navigator);
    searchController.dispose();
    super.dispose();
  }

  Widget secondSearchResult() {
    List<BikeSettingSearchContainer> bikeContainer2List = [];
    _searchSecondResult.forEach((key, value) {
      bikeContainer2List.add(BikeSettingSearchContainer(bikeSettingModel: value, searchResult: key, currentSearchString: searchController.text.trim().toString(),));
    });

    return Column(
      children: [
        ...bikeContainer2List,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _bikeProvider = Provider.of<BikeProvider>(context);
    _bluetoothProvider = Provider.of<BluetoothProvider>(context);

    deviceConnectResult = _bluetoothProvider.deviceConnectResult;

    setButtonImage();

    if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr) {
      //print("BLE Connected : " + _bluetoothProvider.currentConnectedDevice!);
      //print("Current Bike : " + _bikeProvider.currentBikeModel!.macAddr!);
      if (!isFirstTimeConnected) {
        if (!_bikeProvider.isBlockToast) {
          showConnectionStatusToast(
              _bluetoothProvider, isFirstTimeConnected, context, _navigator);
          isFirstTimeConnected = true;
        }
      }
    }
    else if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice != _bikeProvider.currentBikeModel?.macAddr) {
        isFirstTimeConnected = false;
    }
    else {
      if (!_bikeProvider.isBlockToast) {
        isFirstTimeConnected = false;
        showConnectionStatusToast(
            _bluetoothProvider, isFirstTimeConnected, context, _navigator);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },

      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  Visibility(
                    //visible: widget.source == 'Home',
                    visible: true,
                    child: Column(children: [
                      GestureDetector(
                        onLongPress: (){
                          changeToUserHomePageScreen(context);
                        },
                        child: Padding(
                          padding:
                          EdgeInsets.only(left: 17.w, top: 0, bottom: 0),
                          child: Text(
                            "My Bike Settings",
                            style: EvieTextStyles.target_reference_h1,
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),

                  // const Divider(
                  //   thickness: 2,
                  // ),
                  ],),

              //search bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                child: CustomSearchController(
                  suffixIcon: _isSearching ?
                  GestureDetector(
                    onTap: () {
                      _debouncer.run(() {
                        searchController.text = "";
                        _searchFirstResult.clear();
                        _searchSecondResult.clear();
                        _isSearching = false;
                        setState(() {
                        });
                      });
                    },
                    child: const Icon(Icons.cancel),
                  ) : null,
                  searchController: searchController,
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      _debouncer.run(() {
                        _searchFirstResult.clear();
                        _searchSecondResult.clear();
                        _isSearching = false;
                        setState(() {
                        });
                      });
                    }
                    else {
                      _debouncer.run(() {
                        _searchFirstResult.clear();
                        _searchSecondResult.clear();
                        _isSearching = true;
                        _searchFirstResult.addAll(bikeSettingList
                            .where((BikeSettingModel bikeSettingModel) {
                          if (bikeSettingModel.label.toLowerCase().contains(
                              searchController.text.trim().toLowerCase())) {
                            if (bikeSettingModel.secondLevelLabel != null) {
                              for (var element in bikeSettingModel
                                  .secondLevelLabel!) {
                                if (element.toString().toLowerCase().contains(
                                    searchController.text.trim()
                                        .toLowerCase())) {
                                  setState(() {
                                    _searchSecondResult.putIfAbsent(element.toString(), () => bikeSettingModel);
                                  });
                                }
                              }
                            }
                            return true;
                          }
                          else if (bikeSettingModel.secondLevelLabel != null) {
                            for (var element in bikeSettingModel
                                .secondLevelLabel!) {
                              if (element.toString().toLowerCase().contains(
                                  searchController.text.trim().toLowerCase())) {
                                setState(() {
                                  _searchSecondResult.putIfAbsent(element.toString(), () => bikeSettingModel);
                                });
                              }
                            }
                            return false;
                          }
                          else {
                            _searchFirstResult.clear();
                            return false;
                          }
                        }));
                        setState(() {});
                      });
                    }
                  },
                ),
              ),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        //first widget in row, bike pic
                        Padding(
                          padding:
                          EdgeInsets.fromLTRB(21.w, 16.h, 6.w, 16.h),
                          child: Stack(
                            children: [
                              _bikeProvider.currentBikeModel?.model == 'S1' ?
                              Image(
                                image: const AssetImage("assets/buttons/bike_default_S1.png"),
                                width: 49.h,
                                height: 49.h,
                              ) :
                              _bikeProvider.currentBikeModel?.model == 'T1' ?
                              Image(
                                image: const AssetImage("assets/buttons/bike_default_T1.png"),
                                width: 49.h,
                                height: 49.h,
                              ) :
                              Image(
                                image: const AssetImage("assets/buttons/bike_default_L1.png"),
                                width: 49.h,
                                height: 49.h,
                              )
                              // _bikeProvider.currentBikeModel?.bikeIMG == '' ? Image(
                              //   image: const AssetImage("assets/buttons/bike_left_pic.png"),
                              //   width: 49.h,
                              //   height: 49.h,
                              // ) : ClipOval(
                              //     child: CachedNetworkImage(
                              //     //imageUrl: document['profileIMG'],
                              //     imageUrl:
                              //     _bikeProvider.currentBikeModel!.bikeIMG!,
                              //       placeholder: (context, url) =>
                              //       const CircularProgressIndicator(color: EvieColors.primaryColor,),
                              //       errorWidget: (context, url, error) => Icon(Icons.error),
                              //       width: 49.h,
                              //       height: 49.h,
                              //       fit: BoxFit.cover,
                              //     ),
                              //   ),

                              //second widget in row, stacked onto first widget
                              // Positioned(
                              //   bottom: 0,
                              //   right: 0,
                              //   child: Align(
                              //     alignment: Alignment.bottomRight,
                              //     //onTap camera pic
                              //     child: GestureDetector(
                              //       onTap: () {
                              //
                              //         showCupertinoModalBottomSheet(
                              //           expand: false,
                              //           useRootNavigator: true,
                              //           context: context,
                              //           builder: (context) {
                              //             return SwitchBikeImage();
                              //           },
                              //         );
                              //
                              //       },
                              //       child: SvgPicture.asset(
                              //         "assets/buttons/camera_bike_pic.svg",
                              //         width: 24,
                              //         height: 24,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                                // ),
                            ],
                          )
                        ),

                        ///device name
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: _bikeProvider.isPlanSubscript != null ? _bikeProvider.isPlanSubscript! ? 180.w : 210.w : 180.w, // Set the maximum width here
                            ),
                            child: Text(
                              _bikeProvider.currentBikeModel?.deviceName ?? "",
                              style: EvieTextStyles.h3,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )
                        ),

                        ///purple batch
                        Visibility(
                          visible: _bikeProvider.isPlanSubscript ?? false,
                          child: SvgPicture.asset(
                            "assets/icons/batch_tick.svg",
                            height: 30.w,
                            width: 30.w,
                          ),)
                      ],
                    ),

                    ///bluetooth round button on my bike setting page
                    ///when already connected
                    deviceConnectResult == DeviceConnectResult.connected &&
                        _bluetoothProvider.currentConnectedDevice ==
                            _bikeProvider.currentBikeModel?.macAddr ?
                    Padding(
                      padding: EdgeInsets.only(right: 0),
                      child: SizedBox(
                        // width: 148.w,
                        height: 40.h,
                        child: OutlinedButton(
                          onPressed: () async {
                            await _bluetoothProvider.stopScan();
                            await _bluetoothProvider.disconnectDevice();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 1.0, color: EvieColors.primaryColor),
                            shape: CircleBorder(),
                            elevation: 0.0,
                            backgroundColor: EvieColors.primaryColor,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buttonImage!,
                              ]
                          ),
                        ),
                      ),
                    )
                        : Padding(
                      padding: EdgeInsets.only(right: 0),
                      child: SizedBox(
                        // width:90.w,
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            checkBleStatusAndConnectDevice(
                                _bluetoothProvider, _bikeProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            elevation: 0.0,
                            backgroundColor: EvieColors.pastelPurple,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buttonImage!,
                              ]
                          ),
                        ),
                      ),
                    )

                    ///bluetooth round button ends
                  ],
                ),
              ),

              Divider(
                thickness: 0.5.h,
                color: EvieColors.darkWhite,
                height: 0,
              ),
              FutureBuilder(
                  future: loadDataFuture,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    else if (snapshot.connectionState == ConnectionState.done) {
                      if (!_isSearching) {
                        return Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              // Prevent the notification from reaching the parent
                              return true;
                            },
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  ...bikeSettingList.map((e) => BikeSettingContainer(bikeSettingModel: e)),
                                  Container(
                                    color: Colors.transparent,
                                    height: 43.h,
                                  )
                                ],
                              ),
                            ),
                          ),

                      );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              ..._searchFirstResult.map((e) =>
                                  BikeSettingContainer(bikeSettingModel: e))
                                  ,
                              secondSearchResult(),
                            ],
                          ),
                        );
                      }
                    }
                    else {
                      return Container();
                    }
                  }
              ),
            ],
          )),
    );
  }

  void setButtonImage() {
    if (deviceConnectResult == DeviceConnectResult.connected &&
        _bluetoothProvider.currentConnectedDevice ==
            _bikeProvider.currentBikeModel?.macAddr) {
      buttonImage = SvgPicture.asset(
        "assets/buttons/ble_button_connect.svg",
        width: 52.w,
        height: 50.h,
      );
    }  else if (deviceConnectResult == DeviceConnectResult.connecting ||
        deviceConnectResult == DeviceConnectResult.scanning ||
        deviceConnectResult == DeviceConnectResult.partialConnected) {
      buttonImage =
          Stack(
            children: [
              lottie.Lottie.asset(
                'assets/animations/loading_button.json',
                repeat: true,
                width: 45.w,
                height: 50.h,
              ),
            ],
          );
    }
    else if (deviceConnectResult == DeviceConnectResult.disconnected) {
      buttonImage = SvgPicture.asset(
        "assets/buttons/ble_button_disconnect.svg",
        width: 52.w,
        height: 50.h,
      );
    }
    else {
      buttonImage = SvgPicture.asset(
        "assets/buttons/ble_button_disconnect.svg",
        width: 52.w,
        height: 50.h,
      );
    }
  }
}
