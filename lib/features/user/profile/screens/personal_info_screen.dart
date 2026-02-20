import 'package:flutter/material.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColour.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColour.white,
          title: Row(
            children: [
              back_button(),
              const SizedBox(width: 8),
              Text('Personal Info', style: simple_text_style(fontSize: 18)),
              const Spacer(),
            ],
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: const Text('Working on Profile..'),
        )
    );
  }
}