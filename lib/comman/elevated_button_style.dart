import 'package:flutter/material.dart';
import '../constant/AppColour.dart';

ButtonStyle elevated_button_style({double width = double.infinity}) {
  var wid = width == double.infinity
      ? MediaQueryData.fromView(WidgetsBinding.instance.window).size.width * 0.9
      : width;
  return ElevatedButton.styleFrom(
    minimumSize: Size(wid, 50),
    backgroundColor: AppColour.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  );
}
