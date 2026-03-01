import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/on_boarding_item.dart';


class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            item.icon,
            width: size.width * 0.6,
            height: size.height * 0.2,
            fit: BoxFit.cover,
          ),
          SizedBox(height: size.height * 0.05),
          Text(
            item.title,
            style: simple_text_style(
              fontSize: 20,
              isEllipsisAble: false,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: simple_text_style(
              isEllipsisAble: false,
              fontSize: 16,
              color: AppColour.grey
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}