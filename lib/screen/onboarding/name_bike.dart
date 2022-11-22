import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:open_settings/open_settings.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../api/colours.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_textform.dart';

class NameBike extends StatefulWidget {
  const NameBike({Key? key}) : super(key: key);

  @override
  _NameBikeState createState() => _NameBikeState();
}

class _NameBikeState extends State<NameBike> {

  late CurrentUserProvider _currentUserProvider;
  late BikeProvider _bikeProvider;

  @override
  Widget build(BuildContext context) {
    _currentUserProvider = Provider.of<CurrentUserProvider>(context);
    _bikeProvider = Provider.of<BikeProvider>(context);

    final TextEditingController _bikeNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child:Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child:StepProgressIndicator(
                        totalSteps: 10,
                        currentStep: 5,
                        selectedColor: Color(0xffCECFCF),
                        selectedSize: 4,
                        unselectedColor: Color(0xffDFE0E0),
                        unselectedSize: 3,
                        padding: 0.0,
                        roundedEdges: Radius.circular(16),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      "Name your bike",
                      style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text("Give your bike a unique name. "
                        "Can't think of a name for your bike now? "
                        "No worries, you can always do that later at bike setting page whenever you are ready.",
                      style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w400,height: 0.17.h),),
                    SizedBox(
                      height: 2.h,
                    ),

                    EvieTextFormField(
                      controller: _bikeNameController,
                      obscureText: false,
                      keyboardType: TextInputType.name,
                      hintText: "give your bike a unique name",
                      labelText: "Bike Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bike name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                EdgeInsets.only(left: 16.0, right: 16, bottom: EvieLength.buttonWord_ButtonBottom),
                child: EvieButton(
                  width: double.infinity,
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _bikeProvider.updateBikeName(_bikeNameController.text.trim()).then((result){
                        if(result == true){
                          SmartDialog.show(
                              widget: EvieSingleButtonDialogCupertino
                            (title: "Success",
                              content: "Update successful",
                              rightContent: "Ok",
                              onPressedRight: (){changeToTurnOnNotificationsScreen(context);} ));
                        } else{
                          SmartDialog.show(
                              widget: EvieSingleButtonDialogCupertino
                                (title: "Not Success",
                                  content: "An error occur, try again",
                                  rightContent: "Ok",
                                  onPressedRight: (){SmartDialog.dismiss();} ));
                        }
                      });
                    }
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: EvieLength.buttonWord_WordBottom),
                child:

                SizedBox(
                  height: 4.h,
                  width: 30.w,
                  child:
                  TextButton(
                    child: Text(
                      "Maybe Later",
                      style: TextStyle(fontSize: 9.sp,color: EvieColors.PrimaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                     changeToTurnOnNotificationsScreen(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
