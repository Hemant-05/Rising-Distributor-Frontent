import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:raising_india/constant/AppColour.dart';

Widget buildDetailChip({
  required String? icon,
  required String label,
  required bool isIcon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isIcon && icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SvgPicture.asset(icon, width: 16, height: 16),
          ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Sen',
            fontSize: 14,
            color: AppColour.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}