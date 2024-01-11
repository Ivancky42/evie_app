import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIconData extends IconData {
  const SvgIconData(int codePoint, String fontFamily, String svgPathData)
      : super(codePoint, fontFamily: fontFamily, fontPackage: null);

  static Future<SvgIconData> load(String svgPath, int codePoint) async {
    final svgContent = await rootBundle.loadString(svgPath);
    return SvgIconData(codePoint, 'customSvgFont', svgContent);
  }
}

class DeleteIcon {
  static const IconData customIcon = IconData(0xe800, fontFamily: 'CustomIconFont');
// Add more icons as needed
}