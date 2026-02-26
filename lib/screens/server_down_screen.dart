import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

class ServerDownScreen extends StatelessWidget {
  const ServerDownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // WillPopScope prevents the user from swiping back on Android to bypass this screen
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 100, color: Colors.orange.shade300),
              const SizedBox(height: 24),
              Text(
                'Server is Waking Up ☕',
                style: simple_text_style(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColour.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Because we have in initial stage, it goes to sleep when inactive. Please wait 1 to 2 minutes for it to boot up, then try again.',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColour.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Just pop the screen. If the user does an action and it fails again,
                    // the interceptor will automatically bring this screen back.
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'I\'ve waited, Try Again',
                    style: simple_text_style(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}