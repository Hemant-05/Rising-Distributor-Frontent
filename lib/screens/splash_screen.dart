import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {

    final authService = await context.read<AuthService>();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authService.isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreenA()), // Admin Home
      );
    } else if (authService.isCustomer) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreenU()), // User Home
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()), // Login/Welcome
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(appLogo, width: 100, height: 100),
            const SizedBox(height: 20),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}