import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';

///Default user home page if login is true(display bicycle info)

class UserHomeGeneral extends StatefulWidget{
  const UserHomeGeneral({ Key? key }) : super(key: key);
  @override
  _UserHomeGeneralState createState() => _UserHomeGeneralState();
}

class _UserHomeGeneralState extends State<UserHomeGeneral> {

  late CurrentUserProvider _currentUser;


  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<CurrentUserProvider>(context);
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
                onPressed: () {//smart dialog  can print multiple dialog// back dismiss function
                  showDialog(
                      barrierColor: Colors.black .withOpacity(0.5),
                      context: context,
                      builder: (BuildContext buildContext) {
                        return EvieDoubleButtonDialog(
                          //buttonNumber: "2",
                            title: "Connect",
                            content: "In progress In progress",
                            leftContent: "Cancel",
                            rightContent: "Ok",
                            image: Image.asset("assets/evieBike.png", width: 36,height: 36,),
                            onPressedLeft: (){
                              Navigator.of(context).pop();
                            },
                            onPressedRight: (){
                              Navigator.of(context).pop();
                            });
                      }
                  );


                  /*
                  SmartDialog.show(
                    widget: EvieDoubleButtonDialog(
                        title: "Hello",
                        content: "No Finish yet",
                        leftContent: "Cancel",
                        rightContent: "Ok",
                        image: Image.asset("assets/evieBike.png", width: 36,height: 36,),
                        onPressedLeft: (){
                          SmartDialog.dismiss();
                        },
                        onPressedRight: (){
                          SmartDialog.dismiss();
                        }),
                  );

                   */


                  /*
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

                   */
                },
              ),


              ///Sign out for development purpose
              /*
              EvieButton_LightBlue(
                width: double.infinity,
                child: const Text("Sign Out",
                  style: TextStyle(color: Colors.white,
                    fontSize: 12.0,),
                ),
                onPressed: () {
                  _currentUser.signOut();
                },
              ),

               */

              const SizedBox(
                height: 44.0,
              ),

            ]
        ),
      ),


    );
  }
}