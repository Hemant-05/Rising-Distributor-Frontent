import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/user_service.dart';

class MobileVerificationScreen extends StatefulWidget {
  const MobileVerificationScreen({super.key, this.initialMobileNumber});

  final String? initialMobileNumber;

  @override
  State<MobileVerificationScreen> createState() =>
      _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
  late final TextEditingController _mobileController;
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController(
      text: widget.initialMobileNumber ?? '',
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (!_isValidMobile(mobile)) {
      setState(() => _error = 'Enter a valid 10-digit mobile number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await context.read<UserService>().sendMobileOtp(mobile);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _otpSent = error == null;
      _error = error;
    });
  }

  Future<void> _verifyOtp() async {
    final mobile = _mobileController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'Enter the OTP sent to your mobile number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await context.read<UserService>().verifyMobileOtp(
      mobile,
      otp,
    );
    if (error == null) {
      await context.read<AuthService>().loadUserFromStorage();
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = error;
    });

    if (error == null) {
      Navigator.pop(context, true);
    }
  }

  bool _isValidMobile(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length == 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text(
              'Verify Mobile',
              style: simple_text_style(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone_android, color: AppColour.primary, size: 52),
                  const SizedBox(height: 18),
                  Text(
                    'Mobile number required',
                    style: simple_text_style(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We need a verified mobile number before confirming your order.',
                    style: simple_text_style(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      isEllipsisAble: false,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _field(
                    controller: _mobileController,
                    label: 'Mobile number',
                    icon: Icons.phone_outlined,
                    enabled: !_otpSent,
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 16),
                    _field(
                      controller: _otpController,
                      label: 'OTP',
                      icon: Icons.message_outlined,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: simple_text_style(
                        color: AppColour.red,
                        isEllipsisAble: false,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_otpSent ? _verifyOtp : _sendOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColour.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : Text(
                              _otpSent ? 'Verify OTP' : 'Send OTP',
                              style: simple_text_style(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (_otpSent)
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _otpSent = false;
                                  _otpController.clear();
                                  _error = null;
                                });
                              },
                        child: Text(
                          'Change mobile number',
                          style: simple_text_style(color: AppColour.primary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColour.primary, width: 2),
        ),
      ),
    );
  }
}
