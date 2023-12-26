import 'dart:collection';
import 'dart:convert';

import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/api/model/notification_setting_model.dart';
import 'package:evie_test/api/model/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_bike_model.dart';

class SharedPreferenceProvider with ChangeNotifier {
  Future <SharedPreferences> sharedPreferences = SharedPreferences.getInstance();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late SharedPreferences prefs;

  static const userId = "uid";
  static const isFirstLocationRequest = 'location';
  static const isFirstFeedRequest = 'feed';

  static const generalTopic = '~general';
  static const promoTopic = '~promo';
  static const firmwareUpdateTopic = '~firmware-update';

  String? _uid;
  String? get uid => _uid;

  String? _location;
  String? get location => _location;

  String? _feed;
  String? get feed => _feed;


  UserModel? currentUserModel;
  NotificationSettingModel? currentNotificationSettings;
  LinkedHashMap currentUserBikeList = LinkedHashMap<String, BikeModel>();
  bool mapsAreEqual = true;

  void init() async {
    prefs = await sharedPreferences;
    await getFirstLocationRequest();
    await getFirstFeedRequest();
  }

  Future<void> update(UserModel? userModel, NotificationSettingModel? notificationSettings, userBikeDetails) async {
    prefs = await sharedPreferences;
    await getFirstLocationRequest();
    await getFirstFeedRequest();
    if (userModel != null) {
      if (currentUserModel != userModel) {
        if (currentUserModel?.uid != userModel.uid) {
          currentUserModel = userModel;
          await setUid(currentUserModel!.uid);
        }
      }
    }

    if (userBikeDetails != null) {

      if (currentUserBikeList.length != userBikeDetails.length) {
        // If the sizes are different, the maps are definitely not equal
        mapsAreEqual = false;
      }
      else {
        for (var key in currentUserBikeList.keys) {
          NotificationSettingModel? currentNotificationSettings = currentUserBikeList[key].notificationSettings;
          NotificationSettingModel? notificationSettings = userBikeDetails[key].notificationSettings;

          if (currentNotificationSettings != notificationSettings) {
            mapsAreEqual = false;
            break;
          }
        }
      }

      if (!mapsAreEqual) {
        // Handle the case where the maps are different, and possibly update currentUserBikeList

        List<String> bikeListKey = await loadCurrentUserBikeListKeysFromSharedPreferences();
        // Convert the list to a set for easier comparison
        Set<String> bikeListKeySet = Set<String>.from(bikeListKey);
        Set<String> userBikeDetailsKeys = userBikeDetails.keys.toSet();

        // Find keys that are in bikeListKeySet but not in userBikeDetailsKeys
        Set<String> differentKeys = bikeListKeySet.difference(userBikeDetailsKeys);
        if (differentKeys.isNotEmpty) {
          for (var key in differentKeys) {
            await removeValueFromSharedPreferencesList('currentUserBikeListKeys', key);
            //print('Removed : ' + key);
            handleSubTopic("$key~connection-lost", false);
            handleSubTopic("$key~movement-detect", false);
            handleSubTopic("$key~theft-attempt", false);
            handleSubTopic("$key~lock-reminder", false);
            handleSubTopic("$key~plan-reminder", false);
            handleSubTopic("$key~evkey", false);
          }
        } else {
          //print("All keys are the same");
        }


        currentUserBikeList = LinkedHashMap<String, BikeModel>.from(userBikeDetails);
        LinkedHashMap<String, BikeModel> currentUserBikeDetails = LinkedHashMap<String, BikeModel>.from(userBikeDetails);
        saveCurrentUserBikeListKeysToSharedPreferences(currentUserBikeDetails);

        mapsAreEqual = true;

        final keys = currentUserBikeList.keys.toList();
        final values = currentUserBikeList.values.toList();

        for (int i = 0; i < currentUserBikeList.length; i++) {
          final key = keys[i];
          BikeModel bikeModel = values[i];
          NotificationSettingModel? notificationSettings = bikeModel
              .notificationSettings;
          bool? connectionLost = notificationSettings?.connectionLost ??
              false;
          bool? movementDetect = notificationSettings?.movementDetect ??
              false;
          bool? theftAttempt = notificationSettings?.theftAttempt ?? false;
          bool? lockReminder = notificationSettings?.lock ?? false;
          bool? planReminder = notificationSettings?.planReminder ?? true;
          bool? evKey = notificationSettings?.evKey ?? true;

          handleSubTopic("$key~connection-lost", connectionLost);
          handleSubTopic("$key~movement-detect", movementDetect);
          handleSubTopic("$key~theft-attempt", theftAttempt);
          handleSubTopic("$key~lock-reminder", lockReminder);
          handleSubTopic("$key~plan-reminder", planReminder);
          handleSubTopic("$key~evkey", evKey);
        }
      }
    }

    if (notificationSettings != null) {
      if (currentNotificationSettings != notificationSettings) {
        if (currentNotificationSettings?.general != notificationSettings.general) {
          if (notificationSettings?.general == true) {
            await subscribeToTopic(generalTopic);
          }
          else {
            await unsubscribeFromTopic(generalTopic);
          }
        }

        if (currentNotificationSettings?.promo != notificationSettings.promo) {
          if (notificationSettings?.promo == true) {
            await subscribeToTopic(promoTopic);
          }
          else {
            await unsubscribeFromTopic(promoTopic);
          }
        }

        if (currentNotificationSettings?.firmwareUpdate != notificationSettings.firmwareUpdate) {
          if (notificationSettings?.firmwareUpdate == true) {
            await subscribeToTopic(firmwareUpdateTopic);
          }
          else {
            await unsubscribeFromTopic(firmwareUpdateTopic);
          }
        }

        currentNotificationSettings = notificationSettings;
      }
    }
    else {
      await unsubscribeFromTopic(generalTopic);
      await unsubscribeFromTopic(promoTopic);
      await unsubscribeFromTopic(firmwareUpdateTopic);
    }
  }

  /// ******************/
  /// * User Uid *******/
  /// ******************/

  Future<void> setUid(String uid) async {
    await prefs.setString(userId, uid);
    if (uid != '') {
      await subscribeToTopic(uid);
      await subscribeToTopic('abc');
    }
  }

  Future<String?> getUid() async {
    _uid = prefs.getString(userId).toString();
    return _uid;
  }

  Future<void> removeUid() async {
    String? uid = await getUid();
    if (uid != null) {
      currentUserModel = null;
      await prefs.remove(userId);
      unsubscribeFromTopic(uid);
      unsubscribeFromTopic('abc');
    }
  }

  Future<void> setIsFirstLocationRequest(String result) async {
    await prefs.setString(isFirstLocationRequest, result);
    _location = result;
    notifyListeners();
  }

  Future<String?> getFirstLocationRequest() async {
    _location = prefs.getString(isFirstLocationRequest).toString();
    notifyListeners();
    return _location;
  }

  Future<void> setIsFirstFeedRequest(String result) async {
    await prefs.setString(isFirstFeedRequest, result);
    _feed = result;
    notifyListeners();
  }

  Future<String?> getFirstFeedRequest() async {
    _feed = prefs.getString(isFirstFeedRequest).toString();
    notifyListeners();
    return _feed;
  }

  ///Subscribe function block
  subscribeToTopic(String? topic) async {
    await messaging.subscribeToTopic(topic!);
  }

  ///Unsubscribe function block
  unsubscribeFromTopic(String? topic) async {
    await messaging.unsubscribeFromTopic(topic!);
  }

  handleSubTopic(String? topic, bool isSubscribe) async {
    if (isSubscribe) {
      await messaging.subscribeToTopic(topic!);
    }
    else {
      await messaging.unsubscribeFromTopic(topic!);
    }
  }

  // Save currentUserBikeList keys to SharedPreferences
  Future<void> saveCurrentUserBikeListKeysToSharedPreferences(LinkedHashMap<String, BikeModel> currentUserBikeList) async {
    final keysList = currentUserBikeList.keys.toList();
    await prefs.setStringList('currentUserBikeListKeys', keysList);
  }

// Load currentUserBikeList keys from SharedPreferences
  Future<List<String>> loadCurrentUserBikeListKeysFromSharedPreferences() async {
    final keysList = prefs.getStringList('currentUserBikeListKeys');
    return keysList ?? []; // Return an empty list if the keys aren't found
  }

  // Remove a specific value from the list stored in SharedPreferences
  Future<void> removeValueFromSharedPreferencesList(String key, String value) async {
    final keysList = prefs.getStringList(key);

    if (keysList != null) {
      keysList.remove(value); // Remove the value from the list
      await prefs.setStringList(key, keysList); // Save the modified list back to SharedPreferences
    }
  }

  Future<void> clear() async {
    await removeUid();
    currentUserBikeList.clear();
    mapsAreEqual = true;
    currentNotificationSettings = null;
    unsubscribeFromTopic(generalTopic);
    unsubscribeFromTopic(promoTopic);
    unsubscribeFromTopic(firmwareUpdateTopic);
    List<String> bikeListKey = await loadCurrentUserBikeListKeysFromSharedPreferences();
    // Convert the list to a set for easier comparison
    Set<String> bikeListKeySet = Set<String>.from(bikeListKey);
    for (var key in bikeListKeySet) {
      await removeValueFromSharedPreferencesList('currentUserBikeListKeys', key);
      handleSubTopic("$key~connection-lost", false);
      handleSubTopic("$key~movement-detect", false);
      handleSubTopic("$key~theft-attempt", false);
      handleSubTopic("$key~lock-reminder", false);
      handleSubTopic("$key~plan-reminder", false);
      handleSubTopic("$key~evkey", false);
    }
  }
}