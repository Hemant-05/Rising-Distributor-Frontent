import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

import 'package:raising_india/constant/ConString.dart';
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
  bool isTruecallerUsable = false;

  bool isNumberVerified = false;
  bool isLoading = false;
  Timer? timer;
  int t = 30;

  // --- Truecaller & Firebase Variables ---
  StreamSubscription? _truecallerSub;
  String _codeVerifier = '';
  String? _firebaseVerificationId;

  @override
  void initState() {
    super.initState();
    setStatusBarColor();
    _initTruecaller();
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  // ===========================================================================
  // ✅ 1. TRUECALLER OAUTH 2.0 LOGIC (FIXED)
  // ===========================================================================
  void _initTruecaller() async {
    TcSdk.initializeSDK(sdkOption: TcSdkOptions.OPTION_VERIFY_ONLY_TC_USERS);

    bool usable = await TcSdk.isOAuthFlowUsable;
    if (mounted) {
      setState(() {
        isTruecallerUsable = usable;
      });
    }

    _truecallerSub = TcSdk.streamCallbackData.listen((event) async {
      if (event.result == TcSdkCallbackResult.success) {
        setState(() => isLoading = true);

        // The OAuth token from Truecaller
        String authCode = event.tcOAuthData?.authorizationCode ?? '';

        // Call the service to send AuthCode and CodeVerifier to Spring Boot
        final error = await context.read<UserService>().verifyTruecaller(authCode, _codeVerifier);

        if (!mounted) return;
        setState(() => isLoading = false);

        if (error == null || error == 'success') {
          _navigateHome();
        } else {
          setState(() => _error = error);
        }
      } else if (event.result == TcSdkCallbackResult.failure || event.result == TcSdkCallbackResult.verification) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Truecaller verification failed. Please use SMS.')),
        );
      }
    });
  }

  Future<void> _triggerTruecaller() async {
    try {
      // 1. Generate the Verifier using Truecaller's built-in tool
      String? codeVerifier = await TcSdk.generateRandomCodeVerifier;

      if (codeVerifier != null) {
        _codeVerifier = codeVerifier; // Save to send to backend later

        // 2. Generate the Challenge
        String? codeChallenge = await TcSdk.generateCodeChallenge(codeVerifier);

        if (codeChallenge != null) {
          // 3. Configure the OAuth request
          TcSdk.setOAuthState(DateTime.now().millisecondsSinceEpoch.toString());

          // ✅ FIX 1: Removed 'openid' to prevent scope errors.
          TcSdk.setOAuthScopes(['profile', 'phone']);

          // 4. Set the challenge
          await TcSdk.setCodeChallenge(codeChallenge);

          // 5. Trigger the bottom sheet
          TcSdk.getAuthorizationCode;
        }
      }
    } on PlatformException {
      // ✅ FIX 2: Catch the exception if Truecaller is missing or unsupported
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Truecaller app not found or unsupported on this device. Please use SMS OTP.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred with Truecaller.'), backgroundColor: Colors.red),
      );
    }
  }

  // ===========================================================================
  // ✅ 2. FIREBASE SMS OTP LOGIC (Fallback)
  // ===========================================================================
  Future<void> sendFirebaseOTP() async {
    if (_numberController.text.isEmpty || _numberController.text.length < 10) {
      setState(() => _error = 'Please enter a valid 10-digit number');
      return;
    }

    setState(() {
      isLoading = true;
      _error = null;
    });

    String fullPhoneNumber = "+91${_numberController.text.trim()}";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _verifyFirebaseCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isLoading = false;
          _error = e.message ?? "Verification failed";
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          isLoading = false;
          _firebaseVerificationId = verificationId;
          isNumberVerified = true;
          startTimer();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to ${_numberController.text}'), backgroundColor: AppColour.primary),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _firebaseVerificationId = verificationId;
      },
    );
  }

  Future<void> verifyFirebaseOTP() async {
    if (_verificationCodeController.text.isEmpty) {
      setState(() => _error = 'Please enter OTP');
      return;
    }

    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _firebaseVerificationId!,
        smsCode: _verificationCodeController.text.trim(),
      );
      await _verifyFirebaseCredential(credential);
    } on FirebaseAuthException {
      setState(() {
        isLoading = false;
        _error = "Invalid OTP code. Please try again.";
      });
    }
  }

  Future<void> _verifyFirebaseCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final error = await context.read<UserService>().verifyFirebaseToken(idToken);

        if (!mounted) return;
        setState(() => isLoading = false);

        if (error == null || error == 'success') {
          _navigateHome();
        } else {
          setState(() => _error = error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          _error = "Failed to authenticate with Firebase.";
        });
      }
    }
  }

  // --- Helpers ---
  void _navigateHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget.role == admin ? const HomeScreenA() : const MainScreenU()),
          (route) => false,
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

  @override
  void dispose() {
    _truecallerSub?.cancel();
    timer?.cancel();
    _verificationCodeController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.background,
      body: SafeArea(
        child: Stack(
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
                            height: 40, width: 40,
                            margin: const EdgeInsets.only(top: 20, left: 20),
                            decoration: BoxDecoration(color: AppColour.white, borderRadius: BorderRadius.circular(20)),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColour.black),
                            ),
                          ),
                          const Spacer(),
                          TextButton(onPressed: _navigateHome, child: Text('SKIP', style: simple_text_style(color: AppColour.white, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 10),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Verification', style: bold_text_style(AppColour.white)),
                          const SizedBox(height: 10),
                          Text('Verify your mobile number', style: simple_text_style(color: AppColour.white)),
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 22),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),

                          // 1. Truecaller Button
                          if (isTruecallerUsable && !isNumberVerified) ...[
                            ElevatedButton(
                              onPressed: isLoading ? null : _triggerTruecaller,
                              style: elevated_button_style().copyWith(
                                backgroundColor: WidgetStateProperty.all(Colors.blue.shade700),
                              ),
                              child: isLoading
                                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColour.white))
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified_user, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text('1-Tap Verify with True caller', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                          ],

                          // 2. Firebase Fallback Input
                          cus_text_field(
                            label: 'NUMBER',
                            controller: _numberController,
                            hintText: '9987456225',
                            isNumber: true,
                          ),
                          const SizedBox(height: 20),

                          if (isNumberVerified) ...{
                            cus_text_field(
                              label: 'OTP',
                              controller: _verificationCodeController,
                              hintText: '123456',
                              isNumber: true,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: (t == 0) ? sendFirebaseOTP : null,
                                  child: Text(
                                    'Resend OTP ${t > 0 ? t.toString() : ''}',
                                    style: simple_text_style(color: (t == 0) ? AppColour.primary : AppColour.grey, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          },
                          if (_error != null) ...{
                            Text(_error!, style: TextStyle(fontFamily: 'Sen', color: AppColour.red)),
                            const SizedBox(height: 20),
                          },

                          // Proceed Button
                          ElevatedButton(
                            onPressed: isLoading ? null : (isNumberVerified ? verifyFirebaseOTP : sendFirebaseOTP),
                            style: elevated_button_style(),
                            child: isLoading
                                ? SizedBox(height: 30, width: 30, child: CircularProgressIndicator(color: AppColour.white))
                                : Text(isNumberVerified ? 'VERIFY OTP' : 'SEND SMS OTP', style: simple_text_style(color: AppColour.white, fontWeight: FontWeight.bold)),
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