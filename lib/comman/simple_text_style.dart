import 'package:flutter/material.dart';

TextStyle simple_text_style({
  Color color = Colors.black,
  bool isLineThrough = false,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w400,
}) {
  return TextStyle(
    fontFamily: 'Sen',
    fontSize: fontSize,
    color: color,
    decoration: isLineThrough ? TextDecoration.lineThrough : null,
    fontWeight: fontWeight,
    overflow: TextOverflow.ellipsis,
  );
}
