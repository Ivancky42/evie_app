import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CurrentUserProvider extends ChangeNotifier {

  String collection = "users";

  late String _uid;
  late String _email;
  dynamic data;
  late String _name;
  late String _phoneNo;
  late String _profileImageURL;

  String get getUid => _uid;

  String get getEmail => _email;

  String get getName => _name;

  String get getPhoneNo => _phoneNo;

  String get getProfileImageURL => _profileImageURL;

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


  ///Data for user login
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
    FirebaseFirestore.instance.collection(collection).doc(uid)
        .snapshots()
        .listen((event) {
      try {
        _name = event.get('name');
        _phoneNo = event.get('phoneNumber');
        _profileImageURL = event.get('profileIMG');

        notifyListeners();
      } on Exception catch (exception) {
        print(exception.toString());
      }
      catch (error) {
        print(error.toString());
      }
    });
  }


  ///Data for user sign up
  void signUp(String email, String password, String name,
      String phoneNo) async {
    User? firebaseUser;

    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,

    ).then((auth) {
      firebaseUser = auth.user!;
      if (firebaseUser != null) {
        saveToFirestore(firebaseUser!, name, phoneNo).then((value) {
          FirebaseFirestore.instance.collection('UserData')
              .doc(value.user.uid)
              .set({"email": value.user.email});
        });
      }
    }).catchError((error) => print(error));
  }


  ///Upload the registered data to firestore
  saveToFirestore(User fireBaseUser, name, phoneNo) async {
    FirebaseFirestore.instance.collection('users').doc(fireBaseUser.uid).set(
        {
          'uid': fireBaseUser.uid,
          'email': fireBaseUser.email,
          "name": name,
          "phoneNumber": phoneNo,
          //Assign default profile image
          "profileIMG": "https://firebasestorage.googleapis.com/v0/b/evie-testing."
              "appspot.com/o/UserProfilePic%2FDefaultProfilePicCats.jpeg?"
              "alt=media&token=751d024e-8597-439c-8a57-58f0c76ecae0",
          "timeStamp": Timestamp.now(),
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
      var docUser = FirebaseFirestore.instance.collection('users');
      docUser
          .doc(uid)
          .update({
        'name': name,
        'profileIMG': imageURL,
        'phoneNumber': phoneNo,
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
      return Future.delayed(Duration.zero);
    } catch (e) {
      print(e);
    }
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

          _uid = userCredential.user!.uid;
          _email = userCredential.user!.email!;

          Navigator.pushReplacementNamed(context, '/userHomePage');
          //getUser(_uid);
          notifyListeners();
        } catch (error) {
          print(error);
        }
      }
    } catch (error) {
      print(error);
    }



  }


}
//For reference
/*
  Future<dynamic> getData() async {

    final DocumentReference document =   FirebaseFirestore.instance.collection('users')
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid) as DocumentReference<Object?>;

    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      data = snapshot.data;
    });
  }

 */

/*
    FirebaseFirestore.instance.collection('users')
    //Match uid with database
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      value.docs.forEach(((document) {

        name = data['name'];
        phoneNo = data['phoneNumber'];
        profileImageURL = data['profileIMG'];
        notifyListeners();

      }));
    });
     */