import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AddQRInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.trim().replaceAll(RegExp(r'\s+'), '');
    String formattedText = '';

    int firstSpaceIndex = 6;
    int nextSpaceIndex = firstSpaceIndex + 3;
    int lastSpaceIndex = nextSpaceIndex + 5;

    for (int i = 0; i < text.length; i++) {
      if (i == firstSpaceIndex || i == nextSpaceIndex || i == lastSpaceIndex) {
        firstSpaceIndex = nextSpaceIndex + 1;
        nextSpaceIndex = lastSpaceIndex + 1;
        lastSpaceIndex = nextSpaceIndex + 3;
        formattedText += ' ';
      }
      if (i > 14) {
        break;
      }
      formattedText += text[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}