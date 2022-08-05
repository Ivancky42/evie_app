import 'package:flutter/material.dart';


///Button Widget
class EvieButton_DarkBlue extends StatelessWidget {

  final VoidCallback onPressed;
  final Widget child;
  final double width;

  const EvieButton_DarkBlue({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            width: width,

            child: ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  backgroundColor: const Color(0xFF00B6F1),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        )
    );
  }
}


///Button widget
class EvieButton_LightBlue extends StatelessWidget {

  final VoidCallback onPressed;
  final Widget child;
  final double width;

  const EvieButton_LightBlue({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            width: width,

            child: ElevatedButton(
              child: child,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  backgroundColor: const Color(0xFF00B6F1).withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        )
    );
  }
}



class EvieButton_Square extends StatelessWidget {

  final VoidCallback onPressed;
  final double width;
  final double height;
  final Widget icon;

  const EvieButton_Square({
    Key? key,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
        width: width,
          child: Container(
            width: width,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon,
              label: const Text(''),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
    );
  }
}



///Textform widget
class EvieTextForm extends StatelessWidget {

  //final double width;
  //final double height;
  //final double fontSize;
  final String hintText;
  final bool isObscureText;
  final TextEditingController? controller;


  const EvieTextForm({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.isObscureText,
    //required this.width,
    //required this.height,
    //required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      /*width: width,
        height: height,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ReevoColors.secondaryColor,
      ),*/
      child: Padding(padding: EdgeInsets.only(left: 17),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: TextFormField(
              //textAlignVertical : TextAlignVertical.center,
              style: const TextStyle(
                color: Colors.white,
              ),
              controller: controller,
              obscureText: isObscureText,
              decoration: InputDecoration(
                  hintStyle: const TextStyle(
                    //fontSize: fontSize,
                  ),
                  border: InputBorder.none,
                  hintText: hintText
              ),
            ),
          )
      ),
    );
  }
}


///Loading dialog widget
showAlertDialog(BuildContext context){
  AlertDialog alert=AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(margin: EdgeInsets.only(left: 5),child:Text("Loading" )),
      ],),
  );
  showDialog(barrierDismissible: false,
    context:context,
    builder:(BuildContext context){
      return alert;
    },
  );
}


