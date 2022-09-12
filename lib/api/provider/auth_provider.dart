import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../model/user_model.dart';
import '../navigator.dart';
import 'bike_provider.dart';

class AuthProvider extends ChangeNotifier {

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String credentialProvider = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _uid;
  String? _email;

  String? get getUid => _uid;
  String? get getEmail => _email;

  bool isLogin = false;

  AuthProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _uid = user.uid;
        _email = user.email!;
        isLogin = true;
        notifyListeners();
      } else {
        isLogin = false;
      }
    });
  }

  ///User login function
  void login(String email, String password, BuildContext context) async {

    //User Provider
    try {
      UserCredential _authResult = await _auth.
      signInWithEmailAndPassword(email: email, password: password);

      final user = _authResult.user;

      if (user != null) {
        _uid = user.uid;
        _email = user.email!;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Success'),
            duration: Duration(seconds: 2),
          ),
        );

        ///Quit loading and go to user home page
        Navigator.pushReplacementNamed(context, '/userHomePage');

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect Login Info'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      SmartDialog.show(
        widget: EvieSingleButtonDialog(
            title: "Error",
            content: e.toString(),
            rightContent: "Ok",
            image: Image.asset("assets/images/error.png", width: 36,height: 36,),
            onPressedRight: (){
              SmartDialog.dismiss();
            }),
      );
    }
  }


  ///Data for user email sign up
  Future signUp(String email, String password, String name,
      String phoneNo) async {
    User? firebaseUser;
    credentialProvider = "email";

    //Assign default profile image for new register user
    String profileIMG = dotenv.env['DEFAULT_PROFILE_IMG'] ?? 'DPI not found';

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((auth) {
        firebaseUser = auth.user!;
        if (firebaseUser != null) {
          createFirestoreUser(firebaseUser?.uid, firebaseUser?.email, name,
              phoneNo, profileIMG, credentialProvider);
          //    .then((value) {});
        }
      });
      return true;
    }

    catch(e) {
      SmartDialog.show(
        widget: EvieSingleButtonDialog(
            title: "Error",
            content: e.toString(),
            rightContent: "Ok",
            image: Image.asset("assets/images/error.png", width: 36,height: 36,),
            onPressedRight: (){
              SmartDialog.dismiss();
            }),
      );
      debugPrint("false");
    }
  }


  ///Upload the registered data to firestore
  Future createFirestoreUser(uid, email, name, phoneNo, profileIMG, credentialProvider) async {


    try{
      FirebaseFirestore.instance.collection(usersCollection).doc(uid).set(

          UserModel(
            uid: uid,
            email: email,
            name: name,
            phoneNumber: phoneNo,
            //Assign default profile image
            profileIMG: profileIMG,
            credentialProvider: credentialProvider,
            created: Timestamp.now(),
            updated: Timestamp.now(),
          ).toJson()
      );} catch(e) {
      SmartDialog.show(
        widget: EvieSingleButtonDialog(
            title: "Error",
            content: e.toString(),
            rightContent: "Ok",
            image: Image.asset("assets/images/error.png", width: 36,height: 36,),
            onPressedRight: (){
              SmartDialog.dismiss();
            }),
      );
      debugPrint("false");
    }
  }


  ///Change user password
  Future<void> changeUserPassword(BuildContext context, password, originalpassword) async {
    var firebaseUser = _auth.currentUser!;
    if(firebaseUser != null) {
      try {
        await firebaseUser.updatePassword(password);
      } on FirebaseAuthException catch (e){
        SmartDialog.show(
          widget: EvieSingleButtonDialog(
              title: "Error",
              content: e.toString(),
              rightContent: "Ok",
              image: Image.asset("assets/images/error.png", width: 36,height: 36,),
              onPressedRight: (){
                SmartDialog.dismiss();
              }),
        );
        debugPrint(e.toString());
      }
    }
  }



  final GoogleSignIn googleSignIn = GoogleSignIn();
  ///Sign in with google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {


        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);

          if (userCredential.additionalUserInfo!.isNewUser) {
            String? userPhoneNo;

            //Check google phone number
            if(userCredential.user?.phoneNumber != null){
              userPhoneNo = userCredential.user?.phoneNumber.toString();
            }else if(userCredential.user?.phoneNumber == null){
              userPhoneNo = "empty";
            }

            credentialProvider = "google";
            notifyListeners();
            ///Firestore
            AuthProvider().createFirestoreUser(_uid, _email,
                userCredential.user?.displayName.toString(), //Name
                userPhoneNo, //Phone no
                userCredential.user?.photoURL.toString() ,
                credentialProvider//Profile image
            );
            _uid = userCredential.user!.uid;
            _email = userCredential.user!.email!;

            notifyListeners();

          }
          else {
            _uid = userCredential.user!.uid;
            _email = userCredential.user!.email!;

            notifyListeners();
          }

          changeToUserHomePageScreen(context);

        } catch (error) {
          SmartDialog.show(
            widget: EvieSingleButtonDialog(
                title: "Error",
                content: error.toString(),
                rightContent: "Ok",
                image: Image.asset("assets/images/error.png", width: 36,height: 36,),
                onPressedRight: (){
                  SmartDialog.dismiss();
                }),
          );
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }


  ///Sign in with facebook
  Future<void> signInWithFacebook(BuildContext context) async {
    try {

      final LoginResult loginResult = await FacebookAuth.instance.login(
          permissions: [
            'email', 'public_profile'
          ]
      );

      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
      final userCredential = await _auth.signInWithCredential(facebookAuthCredential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        String? userPhoneNo;

        if(userCredential.user?.phoneNumber != null){
          userPhoneNo = userCredential.user?.phoneNumber.toString();
        }else if(userCredential.user?.phoneNumber == null){
          userPhoneNo = "empty";
        }

        credentialProvider = "facebook";
        notifyListeners();

        ///Firestore
        AuthProvider().createFirestoreUser(_uid, _email,
            userCredential.user?.displayName.toString(), //Name
            userPhoneNo, //Phone no
            userCredential.user?.photoURL.toString(),
            credentialProvider//Profile image
        );
        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;

        notifyListeners();

      }
      else {
        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;

        notifyListeners();
      }

      changeToUserHomePageScreen(context);
    } catch (error) {
      SmartDialog.show(
        widget: EvieSingleButtonDialog(
            title: "Error",
            content: error.toString(),
            rightContent: "Ok",
            image: Image.asset("assets/images/error.png", width: 36,height: 36,),
            onPressedRight: (){
              SmartDialog.dismiss();
            }),
      );
    }
  }


  ///Sign in with twitter
  Future<void> signInWithTwitter(BuildContext context) async {
    try {
      final twitterLogin = TwitterLogin(
        apiKey: dotenv.env['TWITTER_API_KEY'] ?? 'TWITTER_API_KEY not found',
        apiSecretKey: dotenv.env['TWITTER_API_SECRET'] ?? 'TWITTER_API_SECRET not found',
        redirectURI: dotenv.env['TWITTER_REDIRECT_URI'] ?? 'Redirect URI not found',
      );

      final authResult = await twitterLogin.loginV2();
      if(authResult.status == TwitterLoginStatus.loggedIn){
        final AuthCredential twitterAuthCredential = TwitterAuthProvider
            .credential(accessToken: authResult.authToken!, secret: authResult.authTokenSecret!);

        try {
          final userCredential = await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
          if (userCredential.additionalUserInfo!.isNewUser) {
            String? userPhoneNo;

            if(userCredential.user?.phoneNumber != null){
              userPhoneNo = userCredential.user?.phoneNumber.toString();
            }else if(userCredential.user?.phoneNumber == null){
              userPhoneNo = "empty";
            }

            credentialProvider = "twitter";
            notifyListeners();

            ///Firestore
            AuthProvider().createFirestoreUser(_uid, _email,
                userCredential.user?.displayName.toString(), //Name
                userPhoneNo, //Phone no
                userCredential.user?.photoURL.toString(),
                credentialProvider//Profile image
            );
            _uid = userCredential.user!.uid;
            _email = userCredential.user!.email!;

            notifyListeners();
          }
          else {
            _uid = userCredential.user!.uid;
            _email = userCredential.user!.email!;

            notifyListeners();
          }

          changeToUserHomePageScreen(context);

        }catch (error) {
          SmartDialog.show(
            widget: EvieSingleButtonDialog(
                title: "Error",
                content: error.toString(),
                rightContent: "Ok",
                image: Image.asset("assets/images/error.png", width: 36,height: 36,),
                onPressedRight: (){
                  SmartDialog.dismiss();
                }),
          );
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  ///Sign in with appleID
  Future<void> signInWithAppleID(BuildContext context) async {
    try {

      credentialProvider = "apple";

    } catch (error) {
      SmartDialog.show(
        widget: EvieSingleButtonDialog(
            title: "Error",
            content: error.toString(),
            rightContent: "Ok",
            image: Image.asset("assets/images/error.png", width: 36,height: 36,),
            onPressedRight: (){
              SmartDialog.dismiss();
            }),
      );
    }
  }

  ///ReAuthentication
  Future<bool> reauthentication(originalpassword) async{
    var firebaseUser = _auth.currentUser!;
    AuthCredential credential = EmailAuthProvider.credential(email:
    getEmail!, password: originalpassword);

    try {
      await firebaseUser.reauthenticateWithCredential(credential);
      debugPrint("true");
      return true;

    }on FirebaseAuthException catch (e){
      SmartDialog.show(
        widget: EvieSingleButtonDialog(
            title: "Error",
            content: e.toString(),
            rightContent: "Ok",
            image: Image.asset("assets/images/error.png", width: 36,height: 36,),
            onPressedRight: (){
              SmartDialog.dismiss();
            }),
      );

      debugPrint("false");
      return false;
    }
  }

  Future<void> resetPassword(email) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .catchError((e) => debugPrint(e));
  }


  ///User sign out
  Future signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      BikeProvider().clear();
      notifyListeners();
      await _auth.signOut();
      if(credentialProvider == "google"){
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      }
      if(credentialProvider == "facebook"){
        await FacebookAuth.instance.logOut();
      }
      if(credentialProvider == "twitter"){
        //twitter sign out
      }
      return Future.delayed(Duration.zero);
    } catch (error) {
      SmartDialog.show(
        widget: EvieSingleButtonDialog(
            title: "Error",
            content: error.toString(),
            rightContent: "Ok",
            image: Image.asset("assets/images/error.png", width: 36,height: 36,),
            onPressedRight: (){
              SmartDialog.dismiss();
            }),
      );
    }
  }

}