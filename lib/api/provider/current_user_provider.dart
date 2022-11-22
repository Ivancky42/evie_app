import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../model/user_model.dart';
import '../todays_quote.dart';
import 'auth_provider.dart';

class CurrentUserProvider extends ChangeNotifier {


  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';

  String? randomQuote;
  bool? isFirstLogin;

  UserModel? currentUserModel;
  UserModel? get getCurrentUserModel => currentUserModel;

  get fetchCurrentUserModel async => currentUserModel;

  ///Initial value
  Future<void> init(uid) async {
    if(uid != null) {
      getUser(uid);
      todayRandomQuote();
      getIsFirstLogin();

      print("isfirstlogin");
      print(isFirstLogin);

      notifyListeners();
    }
  }

  ///Get user information
  void getUser(String? uid) {
    if(uid == null || uid == ""){
      currentUserModel = null;
    } else {
      FirebaseFirestore.instance.collection(usersCollection).doc(uid)
          .snapshots()
          .listen((event) {
        try {
          Map<String, dynamic>? obj = event.data();
          if (obj != null) {
            currentUserModel = UserModel.fromJson(obj);
            notifyListeners();
          }

        } on Exception catch (exception) {
          debugPrint(exception.toString());
        }
        catch (error) {
          debugPrint(error.toString());
        }
      });
    }
  }

  ///User update user profile
  void updateUserProfile(imageURL, name, phoneNo) async {
    try {
      ///Get current user id, might get from provider
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user?.uid;

      //Update
      var docUser = FirebaseFirestore.instance.collection(usersCollection);
      docUser
          .doc(uid)
          .update({
        'name': name,
        'profileIMG': imageURL,
        'phoneNumber': phoneNo,
        'updated': Timestamp.now(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  todayRandomQuote(){
    Random random = Random();
    int randomNumber = random.nextInt(TodaysQuote.quotes.length)+1; // from 1-10
    var randomQuote = TodaysQuote.quotes[randomNumber];
    this.randomQuote = randomQuote;
  }

  Future<void> setIsFirstLogin(bool result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool('isFirstLogin', result);
    isFirstLogin == result;
    getIsFirstLogin();

    notifyListeners();
  }

  Future<void> getIsFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('isFirstLogin')){

      if(prefs.getBool('isFirstLogin') == true){
        isFirstLogin = true;
        notifyListeners();
      }else{
        isFirstLogin = false;
        notifyListeners();
      }
    }else {
      isFirstLogin = true;
      notifyListeners();
    }
  }




}
