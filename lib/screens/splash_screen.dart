import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/on_boarding/screens/welcome_screen.dart';
import 'package:raising_india/features/user/main_screen_u.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/ConPath.dart';
import '../features/auth/bloc/auth_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, curr) => curr is! UserInitial,
      listener: (context, state) async {
        AuthService service = AuthService();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isRememberMe = prefs.getBool('rememberMe') ?? false;
        bool isAdmin = prefs.getBool('isAdmin') ?? false;
        if (isRememberMe ?? state is UserAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => isAdmin ? MainScreenA() : const MainScreenU(),
            ),
          );
        } else {
          await service.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
