import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/auth/screens/signup_screen.dart';
import 'package:raising_india/features/user/coupon/bloc/coupon_bloc.dart';
import 'package:raising_india/features/user/coupon/screens/coupons_screen.dart';
import 'package:raising_india/features/user/profile/bloc/profile_bloc.dart';
import 'package:raising_india/features/auth/bloc/auth_bloc.dart';
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/order/screens/order_screen.dart';
import 'package:raising_india/screens/policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // String userId = FirebaseAuth.instance.currentUser!.uid; // Firebase specific
    // TODO: Get userId from your custom authentication system or UserBloc
    String userId = ""; // Placeholder for now

    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile', style: simple_text_style(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColour.black,
        ),),
        backgroundColor: AppColour.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is OnProfileLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColour.primary,
                      ),
                    );
                  } else if (state is OnProfileLoaded) {
                    userId = state.user!.uid; // Assuming UserBloc provides uid
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColour.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: AppColour.white,
                            size: 50,
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.user?.name}',
                              style: simple_text_style(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${state.user?.email}',
                              style: simple_text_style(
                                fontSize: 14,
                                color: AppColour.lightGrey,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${state.user?.mobileNumber}',
                              style: simple_text_style(
                                color: AppColour.lightGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: Text(
                      'Restart the app.....',
                      style: simple_text_style(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            customContainer(
              Column(
                children: [
                  optionListTile(map_svg, 'Addresses', () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: SelectAddressScreen(isFromProfile: true),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
                  }),
                  optionListTile(coupon_svg, 'Coupons & Cashback\'s', () {
                    context.read<CouponBloc>().add(LoadUserCoupons());
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: CouponsScreen(isSelectionMode: false,),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
                  }),
                ],
              ),
            ),
            customContainer(
              Column(
                children: [
                  optionListTile(receipt_svg, 'My Orders', () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: OrderScreen(),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
                  }),
                  optionListTile(policy_svg, 'Term & Conditions', () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: PolicyScreen(),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );

                  }),
                ],
              ),
            ),
            customContainer(
              optionListTile(logout_svg, 'Log Out', () {
                context.read<UserBloc>().add(UserLoggedOut());
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Logged out...')));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                  (route) => false,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Container customContainer(Widget widget) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(8),
      child: widget,
    );
  }

  ListTile optionListTile(String icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColour.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: SvgPicture.asset(icon, color: AppColour.primary),
      ),
      title: Text(title, style: simple_text_style(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.keyboard_arrow_right_rounded),
    );
  }
}
