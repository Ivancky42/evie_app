import 'package:flutter/material.dart';

class UserHomeHistory extends StatefulWidget{
  const UserHomeHistory({ Key? key }) : super(key: key);
  @override
  _UserHomeHistoryState createState() => _UserHomeHistoryState();

}

class _UserHomeHistoryState extends State<UserHomeHistory> {


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      /*
      appBar: AppBar(title: const Text("History",
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
        centerTitle: false,),

       */

      body: Center(child: Text('History')),
    );
  }

}