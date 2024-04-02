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
import 'package:evie_test/api/provider/shared_pref_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum SignInStatus {
  isNewUser,
  registeredUser,
  failed,
  error,
  cancelled,
}

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

  String? idToken;

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

  Future<void> restoreUserData(context) async {
    userChangeSubscription?.cancel();
    userChangeSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
              if (user.displayName != null) {
                final FirebaseStorage storage = FirebaseStorage.instance;
                final Reference ref = storage.ref().child(
                    checkNameSelectImage(user.displayName!));
                ref.getDownloadURL().then((value) =>
                    updateFirestoreUser(
                        user.uid,
                        user.email,
                        user.displayName,
                        '',
                        value,
                        credentialProvider,
                        ''));
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
              else {
                final FirebaseStorage storage = FirebaseStorage.instance;
                final Reference ref = storage.ref().child(
                    'defaultProfile/rider.png');
                ref.getDownloadURL().then((value) =>
                    updateFirestoreUser(
                        user.uid,
                        user.email,
                        'Evie User',
                        '',
                        value,
                        credentialProvider,
                        ''));
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
      }
      else {
        print('hello');
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
      }
      else {
        return "Incorrect login info";
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        return e.code.toString();
      }
      else {
        return e.toString();
      }
    }
  }

  ///Data for user email sign up
  Future<String?> signUp(String email, String password, String name, String phoneNo) async {
    User? firebaseUser;
    credentialProvider = "email";

    // //Assign default profile image for new register user
    // String profileIMG = dotenv.env['DEFAULT_PROFILE_IMG'] ?? 'DPI not found';

    try {

      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference ref = storage.ref().child(checkNameSelectImage(name));
      final String profileIMG = await ref.getDownloadURL();

      await _auth.createUserWithEmailAndPassword(email: email, password: password,).then((auth) {
        firebaseUser = auth.user!;
        if (firebaseUser != null) {
          firebaseUser?.updateDisplayName(name).then((value) {
            createFirestoreUser(firebaseUser?.uid, firebaseUser?.email, name, phoneNo, profileIMG, credentialProvider, '');
            //sendFirestoreVerifyEmail();
          });
        }
      });
      return 'Success';
    } catch (e) {
      if (e is FirebaseAuthException) {
        debugPrint(e.code.toString());
        return e.code.toString();
      }
      else {
        debugPrint("Unknown exception: $e");
        return "Unknown exception";
      }
    }
  }

  String checkNameSelectImage(String name) {
    final result = containsLowerCase(name[0].toLowerCase());
    if (result) {
      ///random return either 'dark or light'
      final theme = Random().nextBool() ? 'dark' : 'light';
      return 'defaultProfile/' + theme + '-' + name[0].toLowerCase() + '.png';
    }
    else {
      return 'defaultProfile/rider.png';
    }
  }

  bool containsLowerCase(String character) {
    // Define a regular expression to match lowercase letters
    RegExp regExp = RegExp(r'[a-z]');

    // Use the hasMatch method to check if the character contains a lowercase letter
    return regExp.hasMatch(character);
  }

  sendFirestoreVerifyEmail(){
    try {
      User? firebaseUser;
      firebaseUser = _auth.currentUser;
      firebaseUser?.sendEmailVerification();
    }
    catch(error) {
      print(error);
    }
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
            isBetaUser:false,
          ).toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future updateFirestoreUser(uid, email, name, phoneNo, profileIMG, credentialProvider, birthday) async {
    try {
      FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .update(UserModel(
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
        isBetaUser:false,
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
  Future<Map<SignInStatus, String>> signInWithGoogle(String nameInput) async {
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

          final FirebaseStorage storage = FirebaseStorage.instance;
          final Reference ref = storage.ref().child(checkNameSelectImage(userCredential.user?.displayName.toString() ?? ''));
          final String profileIMG = await ref.getDownloadURL();

          if (nameInput != '') {
            ///Firestore
            createFirestoreUser(
                _uid,
                _email,
                nameInput, //Name
                userPhoneNo, //Phone no
                profileIMG,
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
                profileIMG,
                credentialProvider,
                ''
            );
          }

          setIsFirstLogin(true);
          notifyListeners();
          return {SignInStatus.isNewUser: 'Success'};
        }
        else {
          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;
          notifyListeners();
          return {SignInStatus.registeredUser: 'Success'};
        }
      }
      else {
        return {SignInStatus.failed: 'Unknown Error.'};
      }
    } catch (error) {
      debugPrint(error.toString());
      return {SignInStatus.error: error.toString()};
    }
  }

  ///Sign in with facebook
  Future<Map<SignInStatus, String>> signInWithFacebook(String nameInput) async {
    LoginResult loginResult = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
    if (loginResult.status == LoginStatus.cancelled) {
      return {SignInStatus.cancelled: 'User Cancelled.'};
    }
    else if (loginResult.status == LoginStatus.failed) {
      return {SignInStatus.failed: 'Unknown Error'};
    }
    else if (loginResult.status == LoginStatus.success) {
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
      try {
        UserCredential userCredential = await _auth.signInWithCredential(
            facebookAuthCredential);

        credentialProvider = "facebook";
        notifyListeners();

        if (userCredential.additionalUserInfo!.isNewUser) {
          String? userPhoneNo;

          userPhoneNo = "empty";
          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          final FirebaseStorage storage = FirebaseStorage.instance;
          final Reference ref = storage.ref().child(checkNameSelectImage(
              userCredential.user?.displayName.toString() ?? ''));
          final String profileIMG = await ref.getDownloadURL();

          if (nameInput != '') {
            ///Firestore
            createFirestoreUser(
                _uid,
                _email,
                nameInput,
                userPhoneNo,
                //Phone no
                profileIMG,
                credentialProvider,
                ''
            );
          }
          else {
            createFirestoreUser(
                _uid,
                _email,
                userCredential.user?.displayName.toString(),
                userPhoneNo,
                //Phone no
                profileIMG,
                credentialProvider,
                ''
            );
          }

          setIsFirstLogin(true);
          notifyListeners();
          return {SignInStatus.isNewUser: 'Success'};
        }
        else {
          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          notifyListeners();
          return {SignInStatus.registeredUser: 'Success'};
        }
      }
      on FirebaseAuthException catch (e) {
        debugPrint(e.toString());
        return {SignInStatus.error: e.message!};
      }
    }
    else {
      return {SignInStatus.error: loginResult.message!};
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
  Future<Map<SignInStatus, String>> signInWithAppleID(String? nameInput) async {
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
      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

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

        if(nameInput == null || nameInput == "") {
          if(appleCredential.givenName != null){
            userName = appleCredential.givenName;
          }
          else {
            if (userCredential.user?.displayName != null) {
              userName = userCredential.user?.displayName;
            }
            else {
              userName = "Evie User";
            }
          }

        } else{
          userName = nameInput;
        }

        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;

        final FirebaseStorage storage = FirebaseStorage.instance;
        final Reference ref = storage.ref().child(checkNameSelectImage(userName ?? ''));
        final String profileIMG = await ref.getDownloadURL();

        ///Firestore
        createFirestoreUser(
            _uid,
            _email,
            userName,//Name
            userPhoneNo, //Phone no
            //userCredential.user?.photoURL.toString(), ///Cannot get profile image from apple id when first time login, need approval from user
            profileIMG,  //profileimg
            credentialProvider,
            ''
            );

        setIsFirstLogin(true);

        notifyListeners();
        return {SignInStatus.isNewUser : 'Success'};
      } else {
        _uid = userCredential.user!.uid;
        _email = userCredential.user!.email!;

        notifyListeners();
        return {SignInStatus.registeredUser : 'Success'};
      }
    } catch (error) {
      debugPrint(error.toString());
      return {SignInStatus.error : 'Success'};
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

  Future <String?> getIdToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        idToken = await user.getIdToken();
        //print('ID Token: $idToken');
        notifyListeners();
        return idToken;
      } else {
        //print('User is not signed in.');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
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
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(usersCollection)
        .where('email', isEqualTo: email)
        .get();

    for (var element in snapshot.docs) {
      if (element.exists) {
        Map<String, dynamic>? data = element.data() as Map<String, dynamic>?;
        if (data != null) {
          if (!data.containsKey('isDeactivated')) {
            Map<String, dynamic>? obj = element.data() as Map<String, dynamic>?;
            userModel = UserModel.fromJson(obj!);
            break; // Exit the loop once a matching email is found
          }
          else {
            if (data['isDeactivated'] == false) {
              Map<String, dynamic>? obj = element.data() as Map<String,
                  dynamic>?;
              userModel = UserModel.fromJson(obj!);
              break; // Exit the loop once a matching email is found
            }
          }
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
    final _sharedPrefProvider = context.read<SharedPreferenceProvider>();


    await _notificationProvider.clear(_uid!);

    await _auth.signOut();
    await _currentUserProvider.clear();
    await _bikeProvider.clear();
    await _bluetoothProvider.disconnectDevice();
    await _firmwareProvider.clear();
    await _locationProvider.clear();
    await _planProvider.clear();
    await _rideProvider.clear();
    await _sharedPrefProvider.clear();

    if(userChangeSubscription != null){
      userChangeSubscription?.cancel();
    }

    _uid = null;
    isLogin = false;
    notifyListeners();
    return true;
  }
}
