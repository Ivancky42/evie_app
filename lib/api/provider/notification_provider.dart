import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/notification_model.dart';
import '../model/user_model.dart';


class NotificationProvider extends ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String notificationsCollection = dotenv.env['DB_COLLECTION_NOTIFICATIONS'] ?? 'DB not found';

  LinkedHashMap<String, NotificationModel> notificationList = LinkedHashMap<String, NotificationModel>();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationModel? currentSingleNotification;
  UserModel? currentUserModel;
  bool? isReadAll;

  StreamSubscription? notificationListSubscription;
  StreamSubscription? currentNotificationSubscription;

  DateTime? targetActionableBarTime;
  bool isTimeArrive = true;

  Future<void> init(UserModel? currentUserModel) async {
    ///Subscribe to user uid for notification
    notificationList.clear();
    if (currentUserModel == null) {

    }
    else {
      this.currentUserModel = currentUserModel;
      isReadAll = true;
      getNotification(this.currentUserModel!.uid);
      compareActionableBarTime();
      notifyListeners();
    }
  }

  ///Get fcm token
  void firebaseCloudMessaging_Listeners() {
    messaging.getToken().then((newToken) {
      print("FCM toke: $newToken");
    });
  }

  ///Subscribe function block
  subscribeToTopic(String? topic) async {
    await messaging.subscribeToTopic(topic!);
    // debugPrint("Subscribe to : $topic");
  }

  ///Unsubscribe function block
  unsubscribeFromTopic(String? topic) async {
    await messaging.unsubscribeFromTopic(topic!);
    // debugPrint("Unsubscribe to : $topic");
  }

  sendMessageToTopic() async {
    await messaging.sendMessage(

    );
  }

  Future<void> getNotification(String? uid) async {
    try {

      if(notificationListSubscription != null){
        notificationListSubscription?.cancel();
      }

      notificationListSubscription = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .collection(notificationsCollection)
          .orderBy("created", descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
                notificationList.putIfAbsent(docChange.doc.id, () => NotificationModel.fromJson(obj!, docChange.doc.id));

                var sortedByValueMap = LinkedHashMap.fromEntries(notificationList.entries.toList()..sort((e1, e2) => e2.value.created!.compareTo(e1.value.created!)));
                notificationList = sortedByValueMap;

                notifyListeners();
                break;
              case DocumentChangeType.removed:
                notificationList.removeWhere((key, value) => key == docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                notificationList.update(
                    docChange.doc.id,
                    (value) =>
                        NotificationModel.fromJson(obj!, docChange.doc.id));
                notifyListeners();
                break;
            }
          }
        }else{
          notificationList.clear();
          notifyListeners();
        }

      ///Is Read all
        isReadAll = true;
        detectIsReadAll(notificationList);
      });
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    } catch (_) {
      return;
    }
  }

  Future<bool> deleteNotification(String targetNotifyId) async {
    bool result;

    try {
      //Update
      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .collection(notificationsCollection)
          .doc(targetNotifyId)
          .delete();
      result = true;
    } catch (e) {
      debugPrint(e.toString());
      result = false;
    }
    return result;
  }

  Future<void> deleteAllNotification() async {
    final collectionRef = FirebaseFirestore.instance.collection(usersCollection).doc(currentUserModel!.uid).collection(notificationsCollection);

    // Get all documents in the collection
    final querySnapshot = await collectionRef.get();

    // Delete each document
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      if (data['status'] == 'userPending') {

      }
      else {
        await documentSnapshot.reference.delete();
      }
    }
  }

  Future<Object?> getNotificationFromNotificationId(String? notificationId) async {
    currentSingleNotification = null;
    try {

        currentNotificationSubscription?.cancel();

      currentNotificationSubscription = FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .collection(notificationsCollection)
          .doc(notificationId)
          .snapshots()
          .listen((event) {
        if (event.data() != null) {
          Map<String, dynamic>? obj = event.data();

          currentSingleNotification = NotificationModel.fromJson(obj!, event.id);

          //  singleNotificationList.putIfAbsent(
          //      event.id, () => NotificationModel.fromJson(obj!, event.id));
          notifyListeners();
        }else{

        }
      });
      return currentSingleNotification;
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    } catch (_) {
      return currentSingleNotification;
    }
    return null;
  }

  ///Check if all notification is read
  detectIsReadAll(LinkedHashMap<String, NotificationModel> notificationList) {
    notificationList.forEach((key, value) {
      if (value.isRead == false) {
        isReadAll = false;
        notifyListeners();
      }
    });
  }

  updateIsReadStatus(String targetNotifyId) async {
    try {
      //Update
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .collection(notificationsCollection)
          .doc(targetNotifyId)
          .set({
        'isRead': true,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  updateUserNotificationSharedBikeStatus(String targetNotifyId) {
    bool result;
    try {
      //Update
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(currentUserModel!.uid)
          .collection(notificationsCollection)
          .doc(targetNotifyId)
          .delete();
      result = true;
    } catch (e) {
      debugPrint(e.toString());
      result = false;
    }
    return result;
  }

  setSharedPreferenceDate(String target,DateTime dateTime) async{
    SharedPreferences prefs = await _prefs;

    await prefs.setString(target, dateTime.toString());
    compareActionableBarTime();
    notifyListeners();
  }

  Future<void> showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String title, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Change this to a unique channel ID
      'Your Channel Name',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Unique ID for the notification
      title,
      message,
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  compareActionableBarTime()async{
    SharedPreferences prefs = await _prefs;

    if (prefs.containsKey('targetDateTime')) {
      targetActionableBarTime = DateTime.parse(prefs.getString('targetDateTime') ?? "");
      calculateDateDifference(targetActionableBarTime!);
      notifyListeners();
    }else{
      isTimeArrive = true;
    }
  }

  calculateDateDifference(DateTime date) {

    /// Negative : Time not yet arrive
    /// Positive : Time arrive
    /// 0: In between, still consider as not yet arrive

    if(DateTime.now().difference(date).inMinutes > 0){
      isTimeArrive = true;
    }else if(DateTime.now().difference(date).inMinutes <= 0){
      isTimeArrive = false;
    }
    notifyListeners();
  }

  clear(String uid) async {
    notificationList.clear();
    notificationListSubscription?.cancel();
    currentNotificationSubscription?.cancel();
    isTimeArrive = true;
    currentUserModel = null;
    notifyListeners();
  }

}
