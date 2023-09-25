import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:evie_test/api/model/bike_model.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:evie_test/api/provider/plan_provider.dart';
import 'package:evie_test/api/provider/ride_provider.dart';
import 'package:evie_test/api/provider/setting_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../widgets/evie_single_button_dialog.dart';
import '../model/user_model.dart';
import '../navigator.dart';
import 'bike_provider.dart';
import 'bluetooth_provider.dart';
import 'firmware_provider.dart';
import 'location_provider.dart';
import 'notification_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider extends ChangeNotifier {
  String usersCollection = dotenv.env['DB_COLLECTION_USERS'] ?? 'DB not found';
  String credentialProvider = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _uid;
  String? _email;

  String? get getUid => _uid;
  String? get getEmail => _email;

  bool isLogin = false;
  bool? isFirstLogin = false;
  bool? isEmailVerified;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  StreamSubscription? userChangeSubscription;

  AuthProvider() {
    init();
  }


  ///Initial value
  Future<void> init() async {
    userChangeSubscription?.cancel();
    userChangeSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _uid = user.uid;
        _email = user.email!;
        isLogin = true;
        if (user.providerData[0].providerId == 'password') {
          isEmailVerified = user.emailVerified;
        }
        else {
          isEmailVerified = true;
        }
        getIsFirstLogin();
        notifyListeners();
      }
    });
  }

  ///User login function
  Future login(String email, String password) async {
    //User Provider
    try {
      UserCredential _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final user = _authResult.user;

      if (user != null && user.emailVerified == true) {
        _uid = user.uid;
        _email = user.email!;
        isLogin = true;

        notifyListeners();

        return "Verified";
      } else if(user != null && user.emailVerified == false) {
        _uid = user.uid;
        _email = user.email!;

        notifyListeners();

        return "Not yet verify";
      } else {
        return "Incorrect login info";
      }
    } catch (e) {
      return e.toString();
    }
  }

  ///Data for user email sign up
  Future signUp(String email, String password, String name, String phoneNo) async {
    User? firebaseUser;
    credentialProvider = "email";

    //Assign default profile image for new register user
    String profileIMG = dotenv.env['DEFAULT_PROFILE_IMG'] ?? 'DPI not found';

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password,).then((auth) {
        firebaseUser = auth.user!;
        if (firebaseUser != null) {
          createFirestoreUser(firebaseUser?.uid, firebaseUser?.email, name, phoneNo, profileIMG, credentialProvider, '');
          sendFirestoreVerifyEmail();
        }
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  sendFirestoreVerifyEmail(){
    User? firebaseUser;
    firebaseUser = _auth.currentUser;
    firebaseUser!.sendEmailVerification();
  }

  Future checkIsVerify() async {

    if(FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.currentUser!.reload();
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      notifyListeners();

      if (isEmailVerified == true) {
        return true;
      } else {
        return false;
      }
    }else {
      return null;
    }
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
    if (prefs.containsKey('isFirstLogin')) {
      if (prefs.getBool('isFirstLogin') == true) {
        isFirstLogin = true;
        notifyListeners();
      } else {
        isFirstLogin = false;
        notifyListeners();
      }
    } else {
      isFirstLogin = true;
      notifyListeners();
    }
  }

  ///Upload the registered data to firestore
  Future createFirestoreUser(uid, email, name, phoneNo, profileIMG, credentialProvider, birthday) async {
    try {
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .set(UserModel(
            uid: uid,
            email: email,
            name: name,
            phoneNumber: phoneNo,
            //Assign default profile image
            profileIMG: profileIMG,
            credentialProvider: credentialProvider,
            created: Timestamp.now(),
            updated: Timestamp.now(),
            isDeactivated: false,
          ).toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  ///Change user password
  Future changeUserPassword(String password) async {
    var firebaseUser = _auth.currentUser!;
    try {
      await firebaseUser.updatePassword(password);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }


  final GoogleSignIn googleSignIn = GoogleSignIn();

  ///Sign in with google
  Future signInWithGoogle(String nameInput) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        credentialProvider = "google";
        notifyListeners();

        if (userCredential.additionalUserInfo!.isNewUser) {
          String? userPhoneNo;
          //Check google phone number
          if (userCredential.user?.phoneNumber != null) {
            userPhoneNo = userCredential.user?.phoneNumber.toString();
          } else if (userCredential.user?.phoneNumber == null) {
            userPhoneNo = "empty";
          }

          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          if (nameInput != '') {
            ///Firestore
            createFirestoreUser(
                _uid,
                _email,
                nameInput, //Name
                userPhoneNo, //Phone no
                userCredential.user?.photoURL.toString(),
                credentialProvider,
                ''//Profile image
            );
          }
          else {
            createFirestoreUser(
                _uid,
                _email,
                userCredential.user?.displayName.toString(), //Name
                userPhoneNo, //Phone no
                userCredential.user?.photoURL.toString(),
                credentialProvider,
                ''
            );
          }

          setIsFirstLogin(true);
          notifyListeners();
          return true;
        } else {
          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;
          notifyListeners();
          return true;
        }
      }
    } catch (error) {
      debugPrint(error.toString());
      return error.toString();
    }
  }

  ///Sign in with facebook
  Future signInWithFacebook(String nameInput) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);

      if (loginResult.status == LoginStatus.cancelled) {
        ///Show cancel dialog
        print('User cancel');
      }
      else if (loginResult.status == LoginStatus.failed) {
        ///Show failed dialog
        print("User failed");
      }
      else if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

        final userCredential =
        await _auth.signInWithCredential(facebookAuthCredential);

        credentialProvider = "facebook";
        notifyListeners();

        if (userCredential.additionalUserInfo!.isNewUser) {
          String? userPhoneNo;

          userPhoneNo = "empty";


          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          if (nameInput != '') {
            ///Firestore
            createFirestoreUser(
                _uid,
                _email,
                nameInput,
                userPhoneNo, //Phone no
                userCredential.user?.photoURL.toString(),
                credentialProvider,
                ''
            );
          }
          else {
            createFirestoreUser(
                _uid,
                _email,
                userCredential.user?.displayName.toString(),
                userPhoneNo, //Phone no
                userCredential.user?.photoURL.toString(),
                credentialProvider,
                ''
            );
          }

          setIsFirstLogin(true);
          notifyListeners();
          return true;
        }
        else {
          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          notifyListeners();
          return true;
        }
      }
    } catch (error) {
      debugPrint(error.toString());
      return error.toString();
    }
  }

  ///Sign in with twitter
  Future signInWithTwitter(String nameInput) async {
    try {
      final twitterLogin = TwitterLogin(
        apiKey: dotenv.env['TWITTER_API_KEY'] ?? 'TWITTER_API_KEY not found',
        apiSecretKey:
            dotenv.env['TWITTER_API_SECRET'] ?? 'TWITTER_API_SECRET not found',
        redirectURI:
            dotenv.env['TWITTER_REDIRECT_URI'] ?? 'Redirect URI not found',
      );

      final authResult = await twitterLogin.loginV2();
      if (authResult.status == TwitterLoginStatus.loggedIn) {
        final AuthCredential twitterAuthCredential =
            TwitterAuthProvider.credential(
                accessToken: authResult.authToken!,
                secret: authResult.authTokenSecret!);

        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(twitterAuthCredential);
        if (userCredential.additionalUserInfo!.isNewUser) {
          String? userPhoneNo;

          credentialProvider = "twitter";
          notifyListeners();

          if (userCredential.user?.phoneNumber != null) {
            userPhoneNo = userCredential.user?.phoneNumber.toString();
          } else if (userCredential.user?.phoneNumber == null) {
            userPhoneNo = "empty";
          }


          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          ///Firestore
          createFirestoreUser(
              _uid,
              _email,
              //userCredential.user?.displayName.toString(), //Name
              nameInput,
              userPhoneNo, //Phone no
              userCredential.user?.photoURL.toString(),
              credentialProvider,
              ''
              );


          setIsFirstLogin(true);

          notifyListeners();
          return true;
        } else {
          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          notifyListeners();
          return true;
        }
      }
    } catch (error) {
      debugPrint(error.toString());
      return error.toString();
    }
  }

  ///Sign in with appleID
  Future signInWithAppleID(String? nameInput) async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      credentialProvider = "apple";
      notifyListeners();

      if (userCredential.additionalUserInfo!.isNewUser) {
        String? userPhoneNo = "empty";

        // if (userCredential.user?.phoneNumber != null) {
        //   userPhoneNo = userCredential.user?.phoneNumber.toString();
        // } else if (userCredential.user?.phoneNumber == null) {
        //   userPhoneNo = "empty";
        // }

        String? userName = "";

        if(nameInput == null || nameInput == ""){
          if(appleCredential.givenName != null){
            userName = appleCredential.givenName;
          }else{
            userName = "Evie User";
          }
        }else{
          userName = nameInput;
        }

        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;

        ///Firestore
        createFirestoreUser(
            _uid,
            _email,
            userName,//Name
            userPhoneNo, //Phone no
            //userCredential.user?.photoURL.toString(), ///Cannot get profile image from apple id when first time login, need approval from user
            dotenv.env['DEFAULT_PROFILE_IMG'] ?? 'DPI not found',  //profileimg
            credentialProvider,
            ''
            );

        setIsFirstLogin(true);

        notifyListeners();
        return true;
      } else {
        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;

        notifyListeners();
        return true;
      }
    } catch (error) {
      debugPrint(error.toString());
      return error.toString();
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  ///ReAuthentication
  Future<bool> reauthentication(String originalPassword) async {
    var firebaseUser = _auth.currentUser!;
    AuthCredential credential = EmailAuthProvider.credential(
        email: getEmail!, password: originalPassword);

    try {
      await firebaseUser.reauthenticateWithCredential(credential);
      debugPrint("true");
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<UserModel?> checkIfFirestoreUserExist(String email) async {
    UserModel? userModel;

    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection(usersCollection).get();

    for (var element in snapshot.docs) {
      if (element.exists) {
        if (element['email'] == email) {
          Map<String, dynamic>? obj = element.data() as Map<String, dynamic>?;
          userModel = UserModel.fromJson(obj!);

          break; // Exit the loop once a matching email is found
        }
      }
    }

    return userModel;
  }



  Future<void> resetPassword(email) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .catchError((e) => debugPrint(e));
  }

  Future<void> deactivateAccount() async {
    FirebaseFirestore.instance.collection(usersCollection).doc(_uid).update({
      'justDeactivated': true
    });
  }


  ///User sign out
  Future signOut(BuildContext context) async {
    final _currentUserProvider = context.read<CurrentUserProvider>();
    final _bikeProvider = context.read<BikeProvider>();
    final _bluetoothProvider = context.read<BluetoothProvider>();
    final _firmwareProvider = context.read<FirmwareProvider>();
    final _locationProvider = context.read<LocationProvider>();
    final _notificationProvider = context.read<NotificationProvider>();
    final _planProvider = context.read<PlanProvider>();
    final _rideProvider = context.read<RideProvider>();

    await _currentUserProvider.clear();
    await _bikeProvider.clear();
    await _bluetoothProvider.disconnectDevice();
    await _firmwareProvider.clear();
    await _locationProvider.clear();
    await _notificationProvider.clear(_uid!);
    await _planProvider.clear();
    await _rideProvider.clear();

    if(credentialProvider == "google"){
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }

    await _auth.signOut();

    if(userChangeSubscription != null){
      userChangeSubscription?.cancel();
    }

    _uid = null;
    isLogin = false;
    notifyListeners();
    return true;
  }
}
