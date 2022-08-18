import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


///Single button dialog
class EvieSingleButtonDialog extends StatelessWidget{
  // final String buttonNumber;
  final String title;
  final String content;
  final Widget? image;
  final String rightContent;
  final VoidCallback onPressedRight;

  const EvieSingleButtonDialog({
    Key? key,
    //required this.buttonNumber,
    required this.title,
    required this.content,
    this.image,
    required this.rightContent,
    required this.onPressedRight
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
      return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0.0,
      //    backgroundColor: Colors.transparent,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                image != null ? image! : SizedBox(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16,16,16,0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,16,16,0),
                  child: Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(
                  height:30.0,
                ),

                Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        SizedBox(width: 2.w,),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: onPressedRight,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  backgroundColor: const Color(0xff00B6F1)),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 0),
                                child: Text(
                                  rightContent,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            //width: double.infinity, height: 40,
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 20,
            ),
            margin: const EdgeInsets.only(top: 45),
            //decoration: BoxDecoration(
            //  boxShadow: const [
            //    BoxShadow(
            //        color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
            //  ],
              //    gradient: const LinearGradient(
              //      begin: Alignment.topLeft,
              //      end: Alignment.bottomLeft,
              //     stops: [0.0, 1.0],
              //      colors: [
              //        Color(0xffD7E9EF),
              //        Color(0xffD7E9EF),
              //      ],
              //    ),
            //  borderRadius: BorderRadius.circular(16),
              //border: Border.all(color: ReevoColors.blue),
            //),

          )
      );
    },);
  }
}