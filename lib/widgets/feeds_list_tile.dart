
import 'package:evie_bike/api/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../api/colours.dart';
import '../api/function.dart';
import 'evie_button.dart';

class FeedsListTile extends StatelessWidget {

  final String image;
  final String title;
  final String subtitle;
  final bool isDanger;
  final DateTime date;
  final VoidCallback? onPressLeft;
  final VoidCallback onPressRight;

  const FeedsListTile({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.isDanger,
    required this.date,
    this.onPressLeft,
    required this.onPressRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      title:    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                image,
                height: 22.51.h,
                width: 20.w,
              ),
              Text(
                title, style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.lightBlack,
              ),),
            ],
          ),
          Text(calculateTimeAgo(date),
            style: TextStyle(fontSize: 12.sp,color: EvieColors.darkGrayishCyan, fontWeight: FontWeight.w400),),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Connection Lost
          Text(subtitle,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: EvieColors.mediumLightBlack),),
          Padding(
            padding: EdgeInsets.only(top: 9.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isDanger ?
                Expanded(
                  child:  Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: EvieButton_ReversedColor(
                      width: double.infinity,
                      height: 36.h,
                      child: Text(
                        "Learn More",
                        style: TextStyle(
                            color: EvieColors.primaryColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      onPressed: onPressLeft,
                    ),
                  ),
                )
                : Expanded(child: Container()),

                Expanded(
                  child:
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: EvieButton(
                        height: 36.h,
                        child: Text(
                          "Track My Bike",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                        onPressed: onPressRight,
                    ),
                  ),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}