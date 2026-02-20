import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/auth/screens/login_screen.dart';
import '../../../comman/bold_text_style.dart';
import '../widgets/cus_text_field.dart';

class SetNewPassScreen extends StatefulWidget {
  const SetNewPassScreen({super.key, required this.email});
  final String email;

  @override
  State<SetNewPassScreen> createState() => _SetNewPassScreenState();
}

class _SetNewPassScreenState extends State<SetNewPassScreen> {
  final _passController = TextEditingController();
  final _codeController = TextEditingController();
  final _conPasswordController = TextEditingController();

  String? _error;
  bool _isLoading = false;

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

  void _onResetPressed() async {
    if (_passController.text != _conPasswordController.text) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await context.read<AuthService>().resetPassword(
      widget.email,
      _codeController.text.trim(),
      _passController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password Reset Successfully',
            style: simple_text_style(color: AppColour.white),
          ),
          backgroundColor: AppColour.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } else {
      setState(() => _error = error ?? "Failed to reset password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Reset Password', style: bold_text_style(AppColour.white)),
                    const SizedBox(height: 10),
                    Text(
                      'Create a new password for your account',
                      style: simple_text_style(color: AppColour.white),
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
                  padding: const EdgeInsets.all(22),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        cus_text_field(
                          label: 'OTP',
                          controller: _codeController,
                          hintText: '123456',
                        ),
                        const SizedBox(height: 20),
                        cus_text_field(
                          label: 'PASSWORD',
                          controller: _passController,
                          hintText: '********',
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        cus_text_field(
                          label: 'CONFIRM PASSWORD',
                          controller: _conPasswordController,
                          hintText: '********',
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        if (_error != null)
                          Text(
                            _error!,
                            style: simple_text_style(color: AppColour.red),
                          ),
                        if (_error != null) const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _onResetPressed,
                          style: elevated_button_style(),
                          child: _isLoading
                              ? SizedBox(
                            height: 30,
                            width: 30,
                            child: const CircularProgressIndicator(),
                          )
                              : Text(
                            'RESET PASSWORD',
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