import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/auth/screens/login_screen.dart';
import '../../../comman/bold_text_style.dart';
import '../widgets/cus_text_field.dart';
import '../bloc/auth_bloc.dart';


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

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
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
        } else if (state is ResetPasswordError) {
          setState(() => _error = state.message);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                      borderRadius: BorderRadius.only(
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
                            obscureText: false,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(),
                              TextButton(
                                onPressed: () {

                                },
                                child: Text(
                                  'Resend Code',
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
                            Text(
                              _error!,
                              style: simple_text_style(color: AppColour.red),
                            ),
                          if(_error != null )const SizedBox(height: 20),
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              if (state is UserLoading) {
                                return SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: const CircularProgressIndicator(),
                                );
                              }
                              return ElevatedButton(
                                onPressed: () {
                                  String code = _codeController.text.trim(); // Retrieve the code from the previous screen or state
                                  String email = widget.email; // Retrieve the email from the previous screen or state
                                  String password = _passController.text.trim();
                                  String confirmPassword = _conPasswordController.text.trim();
                                  BlocProvider.of<UserBloc>(context).add(
                                    ResetPassword(code: code, email: email, password: password, confirmPassword: confirmPassword)
                                  );
                                },
                                style: elevated_button_style(),
                                child: Text(
                                  'RESET PASSWORD',
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
