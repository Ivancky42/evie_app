import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String notificationsCollection =
      dotenv.env['DB_COLLECTION_NOTIFICATIONS'] ?? 'DB not found';

  LinkedHashMap<String, NotificationModel> notificationList =
      LinkedHashMap<String, NotificationModel>();
  LinkedHashMap<String, NotificationModel> singleNotificationList =
      LinkedHashMap<String, NotificationModel>();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? uid;
  bool? isReadAll = true;

  Future<void> init(String? uid) async {
    ///Subscribe to user uid for notification
    notificationList.clear();
    if (uid == null) {
    } else {
      this.uid = uid;
      subscribeToTopic("fcm_test");
      subscribeToTopic(this.uid);
      getNotification(this.uid);

      //  firebaseCloudMessaging_Listeners();

      notifyListeners();
    }
  }

  ///Get fcm token
  void firebaseCloudMessaging_Listeners() {
    messaging.getToken().then((newToken) {
      print("FCM token");
      print(newToken);
    });
  }

  ///Subscribe function block
  subscribeToTopic(String? topic) async {
    await messaging.subscribeToTopic(topic!);
  }

  ///Unsubscribe function block
  unsubscribeFromTopic(String? topic) async {
    await messaging.unsubscribeFromTopic(topic!);
  }

  Future<void> getNotification(String? uid) async {
    try {
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .collection(notificationsCollection)
          .orderBy("created", descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var docChange in snapshot.docChanges) {
            switch (docChange.type) {

              ///element.type
              case DocumentChangeType.added:
                Map<String, dynamic>? obj = docChange.doc.data();
                notificationList.putIfAbsent(
                    docChange.doc.id, () => NotificationModel.fromJson(obj!));
                notifyListeners();
                break;
              case DocumentChangeType.removed:
                notificationList
                    .removeWhere((key, value) => key == docChange.doc.id);
                notifyListeners();
                break;
              case DocumentChangeType.modified:
                Map<String, dynamic>? obj = docChange.doc.data();
                notificationList.putIfAbsent(
                    docChange.doc.id, () => NotificationModel.fromJson(obj!));
                break;
            }
          }
        }
        isReadAll = true;
        detectIsReadAll(notificationList);
      });
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    } catch (_) {
      return;
    }
  }

  Future getNotificationFromNotificationId(String? notificationId) async {
    singleNotificationList.clear();
    try {
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .collection(notificationsCollection)
          .doc(notificationId)
          .snapshots()
          .listen((event) {
        if (event.data() != null) {
          Map<String, dynamic>? obj = event.data();

          singleNotificationList.putIfAbsent(
              event.id, () => NotificationModel.fromJson(obj!));
          notifyListeners();
        }
      });
      return true;
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    } catch (_) {
      return false;
    }
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
          .doc(uid)
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
          .doc(uid)
          .collection(notificationsCollection)
          .doc(targetNotifyId)
          .set({
        'body': 'You already owned this bike',
        'status': 'shared',
      }, SetOptions(merge: true));
      result = true;
    } catch (e) {
      debugPrint(e.toString());
      result = false;
    }
    return result;
  }
}
