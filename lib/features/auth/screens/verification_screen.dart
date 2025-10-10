import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/admin/home/screens/home_screen_a.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/user/home/screens/home_screen_u.dart';
import 'package:raising_india/features/user/main_screen_u.dart';
import '../../../comman/bold_text_style.dart';
import '../widgets/cus_text_field.dart';
import '../../../comman/elevated_button_style.dart';
import '../../../comman/simple_text_style.dart';
import '../../../constant/AppColour.dart';
import '../../../constant/ConPath.dart';
import '../bloc/auth_bloc.dart';

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
  final AuthService _service = AuthService();
  bool isNumberVerified = false;
  bool isLoading = false;
  String? verificationId;
  int? resendToken;
  Timer? timer;
  int t = 30;

  @override
  void initState() {
    super.initState();
    setStatusBarColor();
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent, // or any color
      ),
    );
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        t -= 1;
        if (t <= 0) {
          t = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> verifyPhone(String phoneNumber, int? resendToken) async {
    setState(() {
      isLoading = true;
      _error = null;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 45),
      verificationCompleted: (PhoneAuthCredential credential) async {
        _service.linkPhoneNumber(credential, phoneNumber);
      },
      verificationFailed: (FirebaseAuthException e) async {
        setState(() {
          _error = e.message;
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          isLoading = false;
          isNumberVerified = true;
          this.resendToken = resendToken;
          this.verificationId = verificationId;
          startTimer();
          showOTPSendSnackBar();
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void resendOTP() {
    String number = _numberController.text.trim();
    verifyPhone(number, resendToken);
    startTimer();
  }

  void showOTPSendSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Your Number ${_numberController.text} is Verified. \nOTP sent successfully...',
        ),
        backgroundColor: AppColour.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  widget.role == admin ? HomeScreenA() : MainScreenU(),
            ),
            (route) => false,
          );
        } else if (state is UserError) {
          setState(() => _error = state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColour.background,
        body: Stack(
          children: [
            Align(
              alignment: Alignment(-2.5, -1.4),
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
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                size: 16,
                                Icons.arrow_back_ios_rounded,
                                color: AppColour.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Verification',
                            style: bold_text_style(AppColour.white),
                          ),
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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 22,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          cus_text_field(
                            label: 'NUMBER',
                            controller: _numberController,
                            hintText: '9987456225',
                            isNumber: true,
                          ),
                          const SizedBox(height: 20),
                          cus_text_field(
                            label: 'OTP',
                            controller: _verificationCodeController,
                            hintText: '1234',
                            isNumber: true,
                          ),
                          const SizedBox(height: 20),
                          if (_error != null) ...{
                            Text(
                              _error!,
                              style: TextStyle(
                                fontFamily: 'Sen',
                                color: AppColour.red,
                              ),
                            ),
                            SizedBox(height: 20),
                          },
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  isNumberVerified && t == 0
                                      ? resendOTP()
                                      : null;
                                },
                                child: Text(
                                  'Resend OTP ${t == 30 || t == 0 ? '' : t.toString()}',
                                  style: simple_text_style(
                                    color: isNumberVerified && t == 0
                                        ? AppColour.primary
                                        : AppColour.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: isNumberVerified
                                    ? () {
                                        if (_verificationCodeController
                                            .text
                                            .isNotEmpty) {
                                          BlocProvider.of<UserBloc>(
                                            context,
                                          ).add(
                                            VerifyOtp(
                                              _verificationCodeController.text
                                                  .trim(),
                                              verificationId!,
                                              _numberController.text.trim(),
                                            ),
                                          );
                                        } else {
                                          setState(() {
                                            _error = 'Please enter otp';
                                          });
                                        }
                                      }
                                    : () {
                                        if (_numberController.text.isNotEmpty) {
                                          verifyPhone(
                                            _numberController.text.trim(),
                                            null,
                                          );
                                        } else {
                                          setState(() {
                                            _error = 'Please enter number';
                                          });
                                        }
                                      },
                                style: elevated_button_style(),
                                child: state is UserLoading || isLoading
                                    ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          color: AppColour.white,
                                        ),
                                      )
                                    : Text(
                                        isNumberVerified
                                            ? 'VERIFY OTP'
                                            : 'VERIFY NUMBER',
                                        style: simple_text_style(
                                          color: AppColour.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              );
                            },
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
      ),
    );
  }
}
