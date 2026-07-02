import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/auth/screens/signup_screen.dart';
import 'package:raising_india/features/user/main_screen_u.dart';

class GoogleAuthChoiceScreen extends StatefulWidget {
  const GoogleAuthChoiceScreen({
    super.key,
    this.returnToPreviousOnSuccess = false,
  });

  final bool returnToPreviousOnSuccess;

  @override
  State<GoogleAuthChoiceScreen> createState() => _GoogleAuthChoiceScreenState();
}

class _GoogleAuthChoiceScreenState extends State<GoogleAuthChoiceScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _continueWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await context.read<AuthService>().signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      if (widget.returnToPreviousOnSuccess) {
        Navigator.pop(context, true);
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreenU()),
        (route) => false,
      );
      return;
    }

    setState(() => _error = error);
  }

  void _openManualSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(appLogo, width: 116, height: 116),
                        const SizedBox(height: 28),
                        Text(
                          'Welcome to Rising Mart',
                          textAlign: TextAlign.center,
                          style: simple_text_style(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColour.black,
                            isEllipsisAble: false,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Use your Google account for quick and secure access.',
                          textAlign: TextAlign.center,
                          style: simple_text_style(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            isEllipsisAble: false,
                          ),
                        ),
                        const SizedBox(height: 34),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _continueWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColour.white,
                              foregroundColor: AppColour.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppColour.primary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: const Text(
                                          'G',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sign in with Google',
                                        style: simple_text_style(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColour.black,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColour.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColour.red.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: simple_text_style(
                                color: AppColour.red,
                                isEllipsisAble: false,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _openManualSignup,
                child: Text(
                  'Sign in / sign up manually',
                  style: simple_text_style(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
