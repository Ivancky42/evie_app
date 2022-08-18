import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../widgets/evie_single_button_dialog.dart';

class CurrentUserProvider extends ChangeNotifier {

  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String credentialProvider = "";

  dynamic data;
  late String _uid;
  late String _email;
  late String _name;
  late String _phoneNo;
  late String _profileImageURL;
  late String _credentialProvider;

  String get getUid => _uid;
  String get getEmail => _email;
  String get getName => _name;
  String get getPhoneNo => _phoneNo;
  String get getProfileImageURL => _profileImageURL;
  String get getCredentialProvider => _credentialProvider;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  CurrentUserProvider() {
    init();
  }

  ///Initial value
  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _uid = user.uid!;
        _email = user.email!;
        getUser(_uid);

        notifyListeners();
      } else {
        _uid = "nullValue";
        notifyListeners();
      }
    });
  }


  ///Data for user login by email
  Future<bool> loginUser(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool retVal = false;
    try {
      UserCredential _authResult = await _auth.
      signInWithEmailAndPassword(email: email, password: password);

      final user = _authResult.user;
      if (user != null) {
        _uid = user.uid;
        _email = user.email!;
        retVal = true;

        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
    return retVal;
  }


  ///Get user information
  void getUser(String? uid) {
    FirebaseFirestore.instance.collection(usersCollection).doc(uid)
        .snapshots()
        .listen((event) {
      try {
        _name = event.get('name');
        _phoneNo = event.get('phoneNumber');
        _profileImageURL = event.get('profileIMG');
        _credentialProvider = event.get('credentialProvider');

        notifyListeners();
      } on Exception catch (exception) {
        print(exception.toString());
      }
      catch (error) {
        print(error.toString());
      }
    });
  }


  ///Data for user email sign up
  Future signUp(BuildContext context, String email, String password, String name,
      String phoneNo) async {
    User? firebaseUser;
    credentialProvider = "email";

    //Assign default profile image for new register user
    String profileIMG = dotenv.env['DEFAULT_PROFILE_IMG'] ?? 'DPI not found';

    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((auth) {
      firebaseUser = auth.user!;
      notifyListeners();
      if (firebaseUser != null) {
        createFirestoreUser(firebaseUser?.uid, firebaseUser?.email, name,
            phoneNo, profileIMG, credentialProvider).then((value) {
        });
      }
    }).catchError((e) {
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
    });
  }


  ///Upload the registered data to firestore
  Future createFirestoreUser(uid, email, name, phoneNo, profileIMG, credentialProvider) async {
    FirebaseFirestore.instance.collection(usersCollection).doc(uid).set(
        {
          'uid': uid,
          'email': email,
          'name': name,
          'phoneNumber': phoneNo,
          //Assign default profile image
          'profileIMG': profileIMG,
          'credentialProvider': credentialProvider,
          'created': Timestamp.now(),
          'updated': Timestamp.now(),
        }
    );
  }


  ///User login function
  void login(String email, String password, BuildContext context,
      CurrentUserProvider _currentUser) async {

    ///From widget function, show loading dialog screen
    //      showAlertDialog(context);

    //User Provider
    try {
      if (await _currentUser.loginUser(email, password)) {
        ///Quit loading and go to user home page
        Navigator.pushReplacementNamed(context, '/userHomePage');

        //Quit loading dialog
        //     Navigator.pop(context);

        getUser(_uid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect Login Info'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
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

      _name = name;
      _phoneNo = phoneNo;
      _profileImageURL = imageURL;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> resetPassword(email) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .catchError((e) => debugPrint(e));
  }



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
            createFirestoreUser(_uid, _email,
                userCredential.user?.displayName.toString(), //Name
                userPhoneNo, //Phone no
                userCredential.user?.photoURL.toString() ,
              credentialProvider//Profile image
            );
            _uid = userCredential.user!.uid;
            _email = userCredential.user!.email!;
            getUser(_uid);
            notifyListeners();

          }
          else {
            _uid = userCredential.user!.uid;
            _email = userCredential.user!.email!;
            getUser(_uid);
            notifyListeners();
          }

          Navigator.pushReplacementNamed(context, '/userHomePage');
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
      print(error);
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
        createFirestoreUser(_uid, _email,
            userCredential.user?.displayName.toString(), //Name
            userPhoneNo, //Phone no
            userCredential.user?.photoURL.toString(),
          credentialProvider//Profile image
        );
        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;
        getUser(_uid);
        notifyListeners();

      }
      else {
        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;
        getUser(_uid);
        notifyListeners();
      }

      Navigator.pushReplacementNamed(context, '/userHomePage');
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
              createFirestoreUser(_uid, _email,
                  userCredential.user?.displayName.toString(), //Name
                  userPhoneNo, //Phone no
                  userCredential.user?.photoURL.toString(),
                credentialProvider//Profile image
              );
              _uid = userCredential.user!.uid;
              _email = userCredential.user!.email!;
              getUser(_uid);
              notifyListeners();
            }
            else {
              _uid = userCredential.user!.uid;
              _email = userCredential.user!.email!;
              getUser(_uid);
              notifyListeners();
            }

            Navigator.pushReplacementNamed(context, '/userHomePage');

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
      print(error);
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
    AuthCredential credential = EmailAuthProvider.credential(email: getEmail!, password: originalpassword);

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
        print(e);
      }
    }
  }


  ///User sign out
  Future signOut() async {
    //While user sign out, set the uid and email empty
    try {
      _uid = "";
      _email = "";
      _name = "";
      _phoneNo = "";
      _profileImageURL = "";
      await FirebaseAuth.instance.signOut();
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
