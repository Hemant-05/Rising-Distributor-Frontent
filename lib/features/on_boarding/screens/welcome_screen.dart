import 'package:flutter/material.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/constant/ConString.dart';
import '../../../comman/bold_text_style.dart';
import '../../../comman/elevated_button_style.dart';
import 'on_boarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                  child: Image.asset(appLogo, width: 150, height: 150)),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(welcome, style: bold_text_style()),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: Text(welcomeDescription, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: elevated_button_style(width: 200),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OnBoardingScreen()),
                        );
                      },
                      child: Text(
                        'Get Started',
                        style: TextStyle(fontSize: 16, color: AppColour.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
