import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


///Double button dialog
class EvieAppbar extends StatelessWidget{
  // final String buttonNumber;
  final String? title;
  final bool? centerTitle;
  final VoidCallback? onPressedBack;
  final Widget? row;

  const EvieAppbar({
    Key? key,
    //required this.buttonNumber,
    this.title,
    this.centerTitle,
    this.onPressedBack,
    this.row,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
      return Scaffold(
        appBar:AppBar(
        centerTitle: centerTitle,
        title: Row(
          children: <Widget>[
            IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
                onPressed: onPressedBack),
            Text(title!),
          ],
        ),
        )
      );
    },);
  }
}