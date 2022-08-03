import 'package:flutter/material.dart';


class UserHomeSetting extends StatefulWidget{
  const UserHomeSetting({ Key? key }) : super(key: key);
  @override
  _UserHomeSettingState createState() => _UserHomeSettingState();

}

class _UserHomeSettingState extends State<UserHomeSetting> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setting"), centerTitle: true,),
      body: Center(child: Text('Setting')),
    );
  }

}