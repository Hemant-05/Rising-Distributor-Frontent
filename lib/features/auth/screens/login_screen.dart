import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import 'package:raising_india/features/user/main_screen_u.dart';
import '../../../comman/bold_text_style.dart';
import '../widgets/cus_text_field.dart';
import 'forgot_pass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool isRememberMe = false;
  bool _isLoading = false; // Local Loading State

  @override
  void initState() {
    super.initState();
    setStatusBarColor();
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  // --- LOGIN LOGIC ---
  void _onLoginPressed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = context.read<AuthService>();

    // Call Service
    final String? error = await authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      // SUCCESS: Check Role and Navigate
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              authService.isAdmin ? const MainScreenA() : const MainScreenU(),
        ),
        (route) => false,
      );
    } else {
      // FAILURE
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.background,
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(-2.5, -1.4),
            child: SvgPicture.asset(
              back_vector_svg,
              color: AppColour.lightGrey.withOpacity(0.2),
              height: 250,
              width: 250,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.only(top: 20, left: 20),
                          decoration: BoxDecoration(
                            color: AppColour.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 16,
                              color: AppColour.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Log In', style: bold_text_style(AppColour.white)),
                        const SizedBox(height: 10),
                        Text(
                          'Please sign in to your existing account',
                          style: simple_text_style(color: AppColour.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColour.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        cus_text_field(
                          label: 'EMAIL',
                          controller: _emailController,
                          hintText: 'example@gmail.com',
                        ),
                        const SizedBox(height: 20),
                        cus_text_field(
                          label: 'PASSWORD',
                          controller: _passwordController,
                          hintText: '********',
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isRememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      isRememberMe = value!;
                                    });
                                  },
                                  activeColor: AppColour.primary,
                                ),
                                Text(
                                  'Remember Me',
                                  style: simple_text_style(
                                    color: AppColour.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPassScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: simple_text_style(
                                  color: AppColour.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_error != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(8),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColour.red.withOpacity(0.1),
                              border: Border.all(color: AppColour.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _error!,
                              style: simple_text_style(color: AppColour.red),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _onLoginPressed,
                          style: elevated_button_style(),
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColour.white,
                                  ),
                                )
                              : Text(
                                  'LOG IN',
                                  style: simple_text_style(
                                    color: AppColour.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
