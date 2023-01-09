import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/screen/my_bike/bike_setting/bike_setting_container.dart';
import 'package:evie_test/screen/my_bike/bike_setting/bike_setting_search_container.dart';
import 'package:evie_test/widgets/custom_search_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

import '../../../api/backend/debouncer.dart';
import '../../../api/colours.dart';
import '../../../api/navigator.dart';
import '../../../api/provider/bike_provider.dart';
import '../../../api/provider/bluetooth_provider.dart';
import '../../../bluetooth/modelResult.dart';
import '../../../widgets/evie_single_button_dialog.dart';
import '../../../widgets/evie_textform.dart';
import '../my_bike_function.dart';
import '../my_bike_widget.dart';
import 'bike_setting_model.dart';



///User profile page with user account information

class BikeSetting extends StatefulWidget {
  const BikeSetting({Key? key}) : super(key: key);

  @override
  _BikeSettingState createState() => _BikeSettingState();
}

class _BikeSettingState extends State<BikeSetting> {

  late BikeProvider _bikeProvider;
  late BluetoothProvider _bluetoothProvider;

  final TextEditingController _bikeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  DeviceConnectResult? deviceConnectResult;
  CableLockResult? cableLockState;
  StreamController? connectStream;
  final searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  List<BikeSettingModel> _searchFirstResult = [];
  LinkedHashMap<String, BikeSettingModel> _searchSecondResult = LinkedHashMap<String, BikeSettingModel>();
  bool _isSearching = false;
  late Future loadDataFuture;

  List<BikeSettingModel> bikeSettingList = [];

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
  void dispose() {
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
                    "My Bike Setting",
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
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
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(27.7.w, 14.67.h, 18.67.w, 14.67.h),
                      child: Image(
                        ///Change based on status
                        image: AssetImage(
                            returnBikeStatusImage(_bikeProvider.currentBikeModel?.location?.isConnected ?? true, _bikeProvider.currentBikeModel?.location?.status ?? "")),
                        width: 86.86.h,
                        height: 54.85.h,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _bikeProvider.currentBikeModel?.deviceName ?? "",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              onPressed: (){
                                SmartDialog.show(
                                    widget: Form(
                                      key: _formKey,
                                      child: EvieDoubleButtonDialog(
                                          title: "Name Your Bike",
                                          childContent: Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:  EdgeInsets.fromLTRB(0.h, 12.h, 0.h, 8.h),
                                                  child: EvieTextFormField(
                                                    controller: _bikeNameController,
                                                    obscureText: false,
                                                    keyboardType: TextInputType.name,
                                                    hintText: _bikeProvider.currentBikeModel?.deviceName ?? "Bike Name",
                                                    labelText: "Bike Name",
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Please enter bike name';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 25.h),
                                                  child: Text("100 Maximum Character", style: TextStyle(fontSize: 12.sp, color: Color(0xff252526)),),
                                                ),
                                              ],
                                            ),
                                          ),
                                          leftContent: "Cancel",
                                          rightContent: "Save",
                                          onPressedLeft: (){SmartDialog.dismiss();},
                                          onPressedRight: (){
                                            if (_formKey.currentState!.validate()) {
                                              _bikeProvider.updateBikeName(_bikeNameController.text.trim()).then((result){
                                                SmartDialog.dismiss();
                                                if(result == true){
                                                  SmartDialog.show(
                                                      keepSingle: true,
                                                      widget: EvieSingleButtonDialogCupertino
                                                        (title: "Success",
                                                          content: "Update successful",
                                                          rightContent: "Ok",
                                                          onPressedRight: (){
                                                            SmartDialog.dismiss();
                                                          } ));
                                                } else{
                                                  SmartDialog.show(
                                                      keepSingle: true,
                                                      widget: EvieSingleButtonDialogCupertino
                                                        (title: "Not Success",
                                                          content: "An error occur, try again",
                                                          rightContent: "Ok",
                                                          onPressedRight: (){SmartDialog.dismiss();} ));
                                                }
                                              });
                                            }

                                          }),
                                    ));
                              },
                              icon:   SvgPicture.asset(
                                "assets/buttons/pen_edit.svg",
                                height:20.h,
                                width: 20.w,
                              ),),
                          ],
                        ),
                        Container(
                          width: 143.w,
                          height: 40.h,
                          child: ElevatedButton(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/bluetooth_small_white.svg",
                                    height:16.h,
                                    width: 16.w,
                                  ),
                                  Text(deviceConnectResult == DeviceConnectResult.connecting || deviceConnectResult == DeviceConnectResult.scanning || deviceConnectResult == DeviceConnectResult.partialConnected ? "Connecting" :_bluetoothProvider.deviceConnectResult == DeviceConnectResult.connected ?  "Connected" : "Connect Bike", style: TextStyle(fontSize: 12.sp, color: Color(0xffECEDEB)),),]
                            ),
                            onPressed: (){
                              checkBLEPermissionAndAction(_bluetoothProvider, deviceConnectResult ?? DeviceConnectResult.disconnected,connectStream);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.w)),
                              elevation: 0.0,
                              backgroundColor: EvieColors.PrimaryColor,
                              //padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 14.h),

                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 0.5.h,
                color: const Color(0xff8E8E8E),
                height: 0,
              ),
              FutureBuilder(
                  future: loadDataFuture,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    else if (snapshot.connectionState == ConnectionState.done) {
                      if (!_isSearching)
                        return Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ...bikeSettingList.map((e) => BikeSettingContainer(bikeSettingModel: e)).toList(),
                              ],
                            ),
                          )
                      );
                      else {
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
