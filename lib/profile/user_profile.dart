import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile extends StatelessWidget{
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       //appBar: AppBar(
       // title: const Text("Welcome!"),
      //),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance
            .collection('users')

        //Match uid with database
            .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return
                Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/userHomePage');
                              }
                          ),

                          const SizedBox(
                            height:50.0,
                          ),

                          Container(
                            child: Center(child: Text(document['name'])),
                          ),


                          Container(
                            child: Center(child: Text(document['email'])),
                          ),

                          Container(
                            child: Center(child: Text(document['phoneNumber'])),
                          ),
                          Container(
                            width: double.infinity,
                            child: RawMaterialButton(
                              elevation: 0.0,
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              onPressed: () async{
                               try{
                                 //await Provider.of(context).auth.signOut();
                                 Navigator.pushReplacementNamed(context, '/home');}
                                   catch(e){print(e);}
                              },
                              child: const Text("Sign Out",
                                style: TextStyle(color: Color(0xFF00B6F1),
                                  fontSize: 12.0,),
                              ),
                            ),
                          ),


                        ])
                );
            }).toList(),
          );
        },
      ),
    );
  }

}