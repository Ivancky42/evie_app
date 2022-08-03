import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUserProvider extends ChangeNotifier{
  late String _uid;
  late String _email;


  String get getUid => _uid;
  String get getEmail => _email;


  final FirebaseAuth _auth = FirebaseAuth.instance;

  CurrentUserProvider() {
    init();
  }


  //Init value for uid
  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _uid = user.uid!;
        _email = user.email!;
        notifyListeners();
      }else{_uid = "nullValue";
        notifyListeners();}
    });
  }


  ///Data for user login
  Future<bool> loginUser(String email, String password) async{
    bool retVal = false;
    try{
      UserCredential _authResult = await _auth.
      signInWithEmailAndPassword(email: email, password: password);

      final user = _authResult.user;
      if(user != null){
        _uid = user.uid;
        _email = user.email!;
        retVal = true;
        notifyListeners();
      }
    }catch (e){
      print(e);}
    return retVal;
  }

  ///Data for user sign up
  Future<bool> signUpUser(String email, String password) async{
    bool retVal = false;
    try{
      //
      notifyListeners();
    }catch (e){print(e);}
    return retVal;
  }


  Future signOut() async {

    try{
      _uid = "";
      _email = "";
      await FirebaseAuth.instance.signOut();
      return Future.delayed(Duration.zero);

    }catch (e){
      print(e);}

    /*
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(EMAIL);
    prefs.remove(UUID);
    prefs.remove(SharedPreferenceProvider.SELECTED_BIKE_BLE_NAME);
    prefs.remove(SharedPreferenceProvider.SELECTED_BIKE_NAME);
    prefs.remove(SharedPreferenceProvider.SELECTED_BIKE_MAC_ADDRESS);
    await FirebaseAuth.instance.signOut();
    _loginState = ApplicationLoginState.loggedOut;
    _uuid = '';


    prefs.setString(EMAIL, "null");
    prefs.setString(UUID, "null");
    prefs.setString(SharedPreferenceProvider.SELECTED_BIKE_BLE_NAME, "null");
    prefs.setString(SharedPreferenceProvider.SELECTED_BIKE_NAME, "null");
    prefs.setString(SharedPreferenceProvider.SELECTED_BIKE_MAC_ADDRESS, "null");
    notifyListeners();
    return Future.delayed(Duration.zero);


    */

  }


}