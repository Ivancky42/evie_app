import 'package:evie_test/api/dialog.dart';
import 'package:evie_test/api/provider/auth_provider.dart';
import 'package:evie_test/api/sizer.dart';
import 'package:evie_test/widgets/evie_single_button_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:evie_test/api/provider/current_user_provider.dart';
import 'package:provider/provider.dart';

import '../../api/colours.dart';
import '../../api/fonts.dart';
import '../../api/length.dart';
import '../../api/navigator.dart';

import 'package:evie_test/widgets/evie_button.dart';

import '../../api/provider/bike_provider.dart';
import '../../widgets/evie_progress_indicator.dart';
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
                    const EvieProgressIndicator(currentPageNumber: 3, totalSteps: 5,),

                    Text(
                      "Name your bike",
                      style: EvieTextStyles.h2,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text("Give your bike a unique name. "
                        "Can't think of a name for your bike now? "
                        "No worries, you can always do that later at bike setting page whenever you are ready.",
                      style: EvieTextStyles.body18,),

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
                    style: EvieTextStyles.ctaBig.copyWith(color: EvieColors.grayishWhite),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _bikeProvider.updateBikeName(_bikeNameController.text.trim()).then((result){
                        if(result == true){
                          /// if(bikeProvider.isAddBike == true) logic inside dialog
                        showAddBikeNameSuccess(context, _bikeProvider, _bikeNameController.text.trim());
                        } else{
                        showAddBikeNameFailed();
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
                padding: EdgeInsets.fromLTRB(0.w,25.h,0.w,EvieLength.buttonWord_WordBottom),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text(
                      "Can't think of any name now",
                      softWrap: false,
                      style: TextStyle(fontSize: 14.sp, fontWeight:FontWeight.w900, color: EvieColors.primaryColor,decoration: TextDecoration.underline,),
                    ),
                    onPressed: () {
                      _bikeProvider.updateBikeName("Evie Bike").then((result){
                        if(result == true){
                          /// if(bikeProvider.isAddBike == true) logic inside dialog
                          showAddBikeNameSuccess(context, _bikeProvider, "Evie Bike");
                        } else{
                          showAddBikeNameFailed();
                        }
                      });
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
