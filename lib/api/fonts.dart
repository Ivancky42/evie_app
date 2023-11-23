
import 'package:evie_test/api/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colours.dart';

class EvieTextStyles {
 static double lineHeight = 1.4;
 static TextStyle h1 = TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w900, height: lineHeight, letterSpacing: 0.3);
 static TextStyle h2 = TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w500, color:EvieColors.mediumBlack, height: lineHeight, letterSpacing: 0.26);
 static TextStyle h3 = TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, height: lineHeight);
 static TextStyle h4 = TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500, height: lineHeight);

 static TextStyle display = TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w900,color: EvieColors.mediumLightBlack, height: lineHeight);
 static TextStyle batteryPercent = TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w800,color: EvieColors.darkGray, height: lineHeight);

 static TextStyle headline = TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500,);
 static TextStyle headlineB = TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.darkGray, height: lineHeight);
 static TextStyle headlineB2 = TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: EvieColors.darkGray, height: lineHeight);
 static TextStyle subHeadline = TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500,);

 static TextStyle ctaSmall = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, height: lineHeight);
 static TextStyle ctaBig = TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, height: lineHeight);

 static TextStyle body12 = TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, height: lineHeight);
 static TextStyle body14 = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, height: lineHeight);
 static TextStyle body16 = TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, height: lineHeight);
 static TextStyle body18 = TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400, height: lineHeight);
 static TextStyle body19 = TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w400, height: lineHeight);
 static TextStyle body20 = TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, height: lineHeight);

 static TextStyle caption = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, height: lineHeight);

 static TextStyle title = TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w800, height: lineHeight);
 static TextStyle miniTitle = TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, height: lineHeight);

 static TextStyle toast = TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: EvieColors.grayishWhite, height: lineHeight);

 static TextStyle measurement = TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w900,color: EvieColors.lightBlack, height: lineHeight);
 static TextStyle unit = TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: EvieColors.darkGrayishCyan, height: lineHeight);

}


