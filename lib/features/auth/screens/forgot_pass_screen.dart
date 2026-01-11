import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/features/auth/screens/set_new_pass_screen.dart';
import '../../../comman/bold_text_style.dart';
import '../widgets/cus_text_field.dart';
import '../../../comman/elevated_button_style.dart';
import '../../../comman/simple_text_style.dart';
import '../../../constant/AppColour.dart';
import '../../../constant/ConPath.dart';
import '../bloc/auth_bloc.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _emailController = TextEditingController();
  String? _error;
  bool success = false;

  @override
  void initState() {
    super.initState();
    setStatusBarColor();
  }

  void navigateToResetScreen(BuildContext context,String email)async{
    await Future.delayed(Duration(seconds: 2));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetNewPassScreen(email: email),
      ),
    );
  }

  void setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is ForgotPasswordState) {
          setState(() {
            success = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'OTP sent on : ${_emailController.text}',
                style: simple_text_style(color: AppColour.white),
              ),
              backgroundColor: AppColour.green,
            ),
          );
          navigateToResetScreen(context, _emailController.text);
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
                            'Forgot Password',
                            style: bold_text_style(AppColour.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Please enter your email to reset your password',
                            style: simple_text_style(color: AppColour.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                          if (success)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: EdgeInsets.all(8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColour.green.withOpacity(0.1),
                                border: Border.all(color: AppColour.green),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'OTP Sent Successfully.. \nPlease Check Your Email : ${_emailController.text}\nInbox or Spam Section.',
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 14,
                                  color: AppColour.green,
                                ),
                              ),
                            ),
                          if (_error != null)
                            Container(
                              margin: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              padding: EdgeInsets.all(8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColour.red.withOpacity(0.1),
                                border: Border.all(color: AppColour.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _error!,
                                style: simple_text_style(
                                  color: AppColour.red,
                                ),
                              ),
                            ),
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: () {
                                  BlocProvider.of<UserBloc>(context).add(
                                    SendVerificationCode(_emailController.text),
                                  );
                                },
                                style: elevated_button_style(),
                                child: (state is UserLoading)
                                    ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          color: AppColour.white,
                                        ),
                                      )
                                    : Text(
                                        'FORGOT PASSWORD',
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
