import 'package:evie_test/api/colours.dart';
import 'package:flutter/material.dart';


///Loading dialog widget
showAlertDialog(BuildContext context){
  AlertDialog alert=AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(color: EvieColors.primaryColor,),
        Container(margin: const EdgeInsets.only(left: 5),child:const Text("Loading" )),
      ],),
  );
  showDialog(barrierDismissible: false,
    context:context,
    builder:(BuildContext context){
      return alert;
    },
  );
}


