import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class CurrentUserProvider extends ChangeNotifier{
  late String _uid;
  late String _email;

  String get getUid => _uid;
  String get getEmail => _email;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///Data for user login
  Future<bool> loginUser(String email, String password) async{
    bool retVal = false;
    try{
      UserCredential _authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);

      final user = _authResult.user;
      if(user != null){
        _uid = user.uid;
        _email = user.email!;
        retVal = true;
      }
    }catch (e){print(e);}
    return retVal;
  }

  ///Data for user sign up
  Future<bool> signUpUser(String email, String password) async{
    bool retVal = false;
    try{
      //
    }catch (e){print(e);}
    return retVal;
  }


}