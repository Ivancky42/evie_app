import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';

class UserHomeGeneral extends StatefulWidget{
  const UserHomeGeneral({ Key? key }) : super(key: key);
  @override
  _UserHomeGeneralState createState() => _UserHomeGeneralState();
}

class _UserHomeGeneralState extends State<UserHomeGeneral> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Home"),centerTitle: true,),
      //Body should change when bottom navigation bar state change
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[


              Image.asset('assets/evieBike.png'),
              const Text(
                'EVIE PRO - Modal A',
                style: TextStyle(fontSize: 20.0),
              ),

              const SizedBox(
                height: 100.0,
              ),

              EvieButton_LightBlue(
                width: double.infinity,
                child: const Text("Connect To Bike",
                  style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hello'),
                      content: const Text('No finish yet'),
                      actions:[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 44.0,
              ),

            ]
        ),
      ),


    );
  }
}