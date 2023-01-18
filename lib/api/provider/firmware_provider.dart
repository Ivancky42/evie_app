import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../model/firmware_model.dart';

class FirmwareProvider extends ChangeNotifier {
  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String bikesCollection = dotenv.env['DB_COLLECTION_BIKES'] ?? 'DB not found';
  String releasesCollection = dotenv.env['DB_COLLECTION_RELEASES'] ?? 'DB not found';
  String firmwareCollection = dotenv.env['DB_COLLECTION_FIRMWARE'] ?? 'DB not found';

  FirmwareModel? latestFirmwareModel;

  String? latestFirmVer;
  String? currentFirmVer;

  bool isLatestFirmVer = false;
  BikeModel? currentBikeModel;

  FirmwareProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
     getFirmwareDetails();
  }

  Future<void> update(BikeModel? currentBikeModel) async {
    this.currentBikeModel = currentBikeModel;
    getFirmwareDetails();
  }

  getFirmwareDetails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(releasesCollection)
        .doc(firmwareCollection)
        .get();

    Map<String, dynamic>? obj = snapshot.data();

    if (obj != null) {
      latestFirmwareModel = FirmwareModel.fromJson(obj);
      notifyListeners();

      getIsCurrentVersion();
    } else {
      latestFirmwareModel = null;
      notifyListeners();
    }

  }

   getIsCurrentVersion() async {
    if(latestFirmwareModel != null && currentBikeModel != null){
      latestFirmVer = latestFirmwareModel!.ver.split("V").last;
      currentFirmVer = currentBikeModel!.firmVer!.split("V").last;

      if(int.parse(currentFirmVer!.replaceAll('.', '')) >= int.parse(latestFirmVer!.replaceAll('.', ''))){
        isLatestFirmVer = true;
        notifyListeners();
      }else{
        isLatestFirmVer = false;
        notifyListeners();
      }
    }
    notifyListeners();
    }


    Future uploadFirmVerToFirestore(String firmVer) async{
      await FirebaseFirestore.instance
          .collection(bikesCollection)
          .doc(currentBikeModel!.deviceIMEI)
          .set({
          "firmVer": firmVer,
      }, SetOptions(merge: true));
    }

   Future<Reference> path(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    return ref;
  }

   Future<File> downloadFile(Reference ref) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');
    if (file.existsSync()) { print("file exist");await file.delete();};
    await ref.writeToFile(file);
    return file;
  }


}
