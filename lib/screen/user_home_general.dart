import 'package:flutter/material.dart';
import 'package:evie_test/widgets/widgets.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:evie_test/widgets/evie_double_button_dialog.dart';
import 'package:evie_test/widgets/evie_button.dart';
import 'package:sizer/sizer.dart';

///Default user home page if login is true(display bicycle info)

class UserHomeGeneral extends StatefulWidget {
  const UserHomeGeneral({Key? key}) : super(key: key);
  @override
  _UserHomeGeneralState createState() => _UserHomeGeneralState();
}

class _UserHomeGeneralState extends State<UserHomeGeneral> {
  late CurrentUserProvider _currentUser;

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<CurrentUserProvider>(context);
    return Scaffold(

      /*
      appBar: AppBar(title: const Text("Home",
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),centerTitle: false,),

       */


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
                height: 80.0,
              ),

              EvieButton_LightBlue(
                height: 12.2.h,
                width: double.infinity,
                child: const Text(
                  "Connect To Bike",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
                onPressed: () {
                  SmartDialog.show(
                      widget: EvieDoubleButtonDialog(
                          //buttonNumber: "2",
                          title: "Connect",
                          content: "In progress",
                          leftContent: "Cancel",
                          rightContent: "Ok",
                          image: Image.asset(
                            "assets/evieBike.png",
                            width: 36,
                            height: 36,
                          ),
                          onPressedLeft: () {
                            SmartDialog.dismiss();
                          },
                          onPressedRight: () {
                            SmartDialog.dismiss();
                          }));
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
                height: 5.0,
              ),
            ]),
      ),
    );
  }
}
