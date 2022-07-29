import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


class FirebaseAuthService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  //Get uid
  Future<String?> getCurrentUID() async{
    final currentUser = _firebaseAuth.currentUser?.uid;
    return currentUser;
  }

  //Get user
  Future getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser;
  }

}


















class LoadDataFromFirestore extends StatefulWidget {
  @override
  _LoadDataFromFirestoreState createState() => _LoadDataFromFirestoreState();
}

class _LoadDataFromFirestoreState extends State<LoadDataFromFirestore> {


  late QuerySnapshot querySnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Data"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Container(
                child: Center(child: Text(document['text'])),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}