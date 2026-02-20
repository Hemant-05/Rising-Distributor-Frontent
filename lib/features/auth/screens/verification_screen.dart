import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/user_service.dart';
import 'package:raising_india/features/admin/home/screens/home_screen_a.dart';
import 'package:raising_india/features/user/main_screen_u.dart';
import '../../../comman/bold_text_style.dart';
import '../widgets/cus_text_field.dart';
import '../../../comman/elevated_button_style.dart';
import '../../../comman/simple_text_style.dart';
import '../../../constant/AppColour.dart';
import '../../../constant/ConPath.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key, required this.role});
  final String role;

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  String? _error;
  final _verificationCodeController = TextEditingController();
  final _numberController = TextEditingController();

  bool isNumberVerified = false; // "OTP Sent" status
  bool isLoading = false;
  Timer? timer;
  int t = 30;

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

  void startTimer() {
    t = 30;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          t -= 1;
          if (t <= 0) {
            t = 0;
            timer.cancel();
          }
        });
      }
    });
  }

  // --- LOGIC: Send OTP ---
  Future<void> sendOTP() async {
    if (_numberController.text.isEmpty) {
      setState(() => _error = 'Please enter number');
      return;
    }

    setState(() {
      isLoading = true;
      _error = null;
    });

    final error = await context.read<UserService>().registerMobile(
      "+91${_numberController.text.trim()}",
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error == null || error == 'success') {
      // Success: OTP Sent
      setState(() {
        isNumberVerified = true; // Flag changes to "OTP Sent"
        startTimer();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${_numberController.text}'),
          backgroundColor: AppColour.primary,
        ),
      );
    } else {
      setState(() => _error = error);
    }
  }

  // --- LOGIC: Verify OTP ---
  Future<void> verifyOTP() async {
    if (_verificationCodeController.text.isEmpty) {
      setState(() => _error = 'Please enter OTP');
      return;
    }

    setState(() {
      isLoading = true;
      _error = null;
    });

    final error = await context.read<UserService>().verifyMobile(
      _verificationCodeController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error == null || error == 'success') {
      // Success: Navigate Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          widget.role == admin ? const HomeScreenA() : const MainScreenU(),
        ),
            (route) => false,
      );
    } else {
      setState(() => _error = error);
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
                        Text('Verification', style: bold_text_style(AppColour.white)),
                        const SizedBox(height: 10),
                        Text(
                          'Verify your mobile number with otp',
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
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 22),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        cus_text_field(
                          label: 'NUMBER',
                          controller: _numberController,
                          hintText: '9987456225',
                          isNumber: true,
                          // Disable editing number after OTP is sent
                        ),
                        const SizedBox(height: 20),
                        if (isNumberVerified) ...{
                          cus_text_field(
                            label: 'OTP',
                            controller: _verificationCodeController,
                            hintText: '1234',
                            isNumber: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: (t == 0) ? sendOTP : null,
                                child: Text(
                                  'Resend OTP ${t > 0 ? t.toString() : ''}',
                                  style: simple_text_style(
                                    color: (t == 0) ? AppColour.primary : AppColour.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        },
                        if (_error != null) ...{
                          Text(
                            _error!,
                            style: TextStyle(fontFamily: 'Sen', color: AppColour.red),
                          ),
                          const SizedBox(height: 20),
                        },
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : (isNumberVerified ? verifyOTP : sendOTP),
                          style: elevated_button_style(),
                          child: isLoading
                              ? SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(color: AppColour.white),
                          )
                              : Text(
                            isNumberVerified ? 'VERIFY OTP' : 'VERIFY NUMBER',
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