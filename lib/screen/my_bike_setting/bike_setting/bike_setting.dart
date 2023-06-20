import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:evie_test/api/function.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:evie_test/widgets/custom_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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
import '../../../widgets/evie_appbar.dart';
import '../my_bike_function.dart';
import 'bike_setting_container.dart';
import 'bike_setting_model.dart';
import 'bike_setting_search_container.dart';


class BikeSetting extends StatefulWidget {
  final String? source;
  const BikeSetting(this.source, {Key? key}) : super(key: key);

  @override
  _BikeSettingState createState() => _BikeSettingState();
}

class _BikeSettingState extends State<BikeSetting> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;
  StreamController? connectStream;

  List<BikeSettingModel> bikeSettingList = [];
  List<BikeSettingModel> _searchFirstResult = [];
  LinkedHashMap<String, BikeSettingModel> _searchSecondResult = LinkedHashMap<String, BikeSettingModel>();

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
    cableLockState = _bluetoothProvider.cableLockState;

    if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr) {
      print("BLE Connected : " + _bluetoothProvider.currentConnectedDevice!);
      print("Current Bike : " + _bikeProvider.currentBikeModel!.macAddr!);
      if (!isFirstTimeConnected) {
        showConnectionStatusToast(_bluetoothProvider, isFirstTimeConnected, context, _navigator);
        isFirstTimeConnected = true;
      }
    }
    else if (deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice != _bikeProvider.currentBikeModel?.macAddr) {
        isFirstTimeConnected = false;
    }
    else {
      isFirstTimeConnected = false;
      showConnectionStatusToast(_bluetoothProvider, isFirstTimeConnected, context, _navigator);
    }

    return WillPopScope(
        onWillPop: () async {

          if(widget.source == 'MyGarage'){
            changeToMyGarageScreen(context);
          }else if(widget.source == 'SwitchBike'){
            changeToUserHomePageScreen(context);
          }else if(widget.source == 'Home'){
            changeToUserHomePageScreen(context);
          }else{
            changeToUserHomePageScreen(context);
          }

      return false;
    },

      child: Scaffold(
          appBar: PageAppbar(
            enable: widget.source != 'Home',
            title: 'My Bike Setting',
            onPressed: () {
              if(widget.source == 'MyGarage'){
                changeToMyGarageScreen(context);
              }else if(widget.source == 'SwitchBike'){
                changeToUserHomePageScreen(context);
              }else if(widget.source == 'Home'){
                changeToUserHomePageScreen(context);
              }else{
                changeToUserHomePageScreen(context);
              }
            },
          ),
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
                        onTap: (){
                          changeToUserHomePageScreen(context);
                        },
                        child: Padding(
                          padding:
                          EdgeInsets.only(left: 17.w, top: 10.h, bottom: 0.h),
                          child: Text(
                            "My Bike Setting",
                            style: EvieTextStyles.h1,
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),

                  const Divider(
                    thickness: 2,
                  ),
                  ],),

              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
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
                height: 96.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Row(
                      children: [
                        Padding(
                          padding:
                          EdgeInsets.fromLTRB(27.7.w, 14.67.h, 6.w, 14.67.h),
                          child: Image(
                            ///Change based on status
                            image: const AssetImage(
                              //returnBikeStatusImage(_bikeProvider.currentBikeModel?.location?.isConnected ?? true, _bikeProvider.currentBikeModel?.location?.status ?? "")),
                                "assets/buttons/bike_update_photo.png"),
                            width: 49.h,
                            height: 49.h,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: Text(
                            _bikeProvider.currentBikeModel?.deviceName ?? "",
                            style: EvieTextStyles.h3,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Visibility(
                          visible: _bikeProvider.isPlanSubscript ?? false,
                          child: SvgPicture.asset(
                            "assets/icons/batch_tick.svg",
                            height: 25.h,
                            width: 25.w,
                          ),)
                      ],
                    ),

                    deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr?
                    Padding(
                      padding: EdgeInsets.only(right:19.w),
                      child: Container(
                        width: 148.w,
                        height: 30.h,
                        child: OutlinedButton(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/bluetooth_small_white.svg",
                                  height:16.h,
                                  width: 16.w,
                                  color: EvieColors.primaryColor,
                                ),
                                Text("Disconnect Bike", style: TextStyle(fontSize: 12.sp, color: EvieColors.primaryColor,)),]
                          ),
                          onPressed: () async {
                            await _bluetoothProvider.stopScan();
                            await _bluetoothProvider.disconnectDevice();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 1.0, color: EvieColors.primaryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            elevation: 0.0,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ) :
                    Padding(
                      padding: EdgeInsets.only(right:19.w),
                      child: Container(
                        width: 143.w,
                        height: 30.h,
                        child: ElevatedButton(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/bluetooth_small_white.svg",
                                  height:16.h,
                                  width: 16.w,
                                ),
                                Text(
                                  deviceConnectResult == DeviceConnectResult.connecting
                                      || deviceConnectResult == DeviceConnectResult.scanning
                                      || deviceConnectResult == DeviceConnectResult.partialConnected ? "Connecting"
                                      :_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected && _bluetoothProvider.currentConnectedDevice == _bikeProvider.currentBikeModel?.macAddr
                                      ?  "Connected" : "Connect Bike", style: TextStyle(fontSize: 12.sp, color: Color(0xffECEDEB)),),]
                          ),
                          onPressed: () async {
                            checkBleStatusAndConnectDevice(_bluetoothProvider, _bikeProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0.0,
                            backgroundColor: EvieColors.primaryColor,
                          ),
                        ),
                      ),
                    )
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
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ...bikeSettingList.map((e) => BikeSettingContainer(bikeSettingModel: e)).toList(),
                              ],
                            ),
                          )
                      );
                      } else {
                        return Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ..._searchFirstResult.map((e) =>
                                      BikeSettingContainer(bikeSettingModel: e))
                                      .toList(),
                                  secondSearchResult(),
                                ],
                              ),
                            )
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
}
