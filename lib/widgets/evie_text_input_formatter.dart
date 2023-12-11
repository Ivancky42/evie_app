import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


class AddQRInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.trim().replaceAll(RegExp(r'\s+'), '');
    String formattedText = '';

    // Define the positions where spaces should be added
    List<int> spacePositions = [6, 10];

    for (int i = 0; i < text.length; i++) {
      // Check if the current position is in the list of space positions
      if (spacePositions.contains(i)) {
        formattedText += ' ';
      }
      // Add the current character to the formatted text
      if (i > 15) {
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