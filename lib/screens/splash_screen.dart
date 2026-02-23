import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import 'package:raising_india/features/on_boarding/screens/welcome_screen.dart';
import 'package:raising_india/features/user/main_screen_u.dart';
import '../constant/ConPath.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {context.read<AuthService>();});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthService>(
        builder: (context, authService, _) {

          // 1. If loading, return the Splash UI
          if (authService.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(appLogo, width: 120, height: 120),
                  const SizedBox(height: 20),
                  Text('Loading...',style: simple_text_style(),),
                ],
              ),
            );
          }

          // 2. If finished loading, RETURN the correct screen directly!
          else {
            if (authService.isAdmin) {
              return const MainScreenA(); // Admin Home
            } else if (authService.isCustomer) {
              return const MainScreenU(); // User Home
            } else {
              return const WelcomeScreen(); // Login/Welcome
            }
          }
        },
      ),
    );
  }
}