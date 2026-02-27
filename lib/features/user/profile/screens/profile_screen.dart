import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';

// Services
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/coupon_service.dart';
import 'package:raising_india/features/auth/screens/login_screen.dart';

// Screens
import 'package:raising_india/features/auth/screens/signup_screen.dart';
import 'package:raising_india/features/on_boarding/screens/welcome_screen.dart';
import 'package:raising_india/features/user/coupon/screens/coupons_screen.dart';
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/order/screens/order_screen.dart';
import 'package:raising_india/features/user/profile/screens/personal_info_screen.dart';
import 'package:raising_india/screens/policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        title: Text(
          'Profile',
          style: simple_text_style(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColour.black,
          ),
        ),
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.customer; // Get current user (Customer)

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // --- PROFILE HEADER ---
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalInfoScreen(),));
                  },
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: user == null
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
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
                        const SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? "User",
                              style: simple_text_style(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user.email ?? "",
                              style: simple_text_style(
                                fontSize: 14,
                                color: AppColour.lightGrey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user.mobileNumber ?? "No Number",
                              style: simple_text_style(
                                color: AppColour.lightGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // --- OPTIONS SECTION 1 ---
                customContainer(
                  Column(
                    children: [
                      optionListTile(map_svg, 'Addresses', () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const SelectAddressScreen(isFromProfile: true),
                          withNavBar: false,
                          pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        );
                      }),
                      optionListTile(coupon_svg, 'Coupons & Cashback\'s', () {
                        // Load coupons before navigating
                        context.read<CouponService>().fetchAllCoupons(); // Assuming you have this specific method
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const CouponsScreen(isSelectionMode: false),
                          withNavBar: false,
                          pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        );
                      }),
                    ],
                  ),
                ),

                // --- OPTIONS SECTION 2 ---
                customContainer(
                  Column(
                    children: [
                      optionListTile(receipt_svg, 'My Orders', () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const OrderScreen(),
                          withNavBar: false,
                          pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        );
                      }),
                      optionListTile(policy_svg, 'Term & Conditions', () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const PolicyScreen(),
                          withNavBar: false,
                          pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        );
                      }),
                    ],
                  ),
                ),

                // --- LOGOUT ---
                customContainer(
                  optionListTile(logout_svg, 'Log Out', () async {
                    await context.read<AuthService>().signOut();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out...')),
                      );
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                      );
                    }
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container customContainer(Widget widget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: widget,
    );
  }

  ListTile optionListTile(String icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColour.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: SvgPicture.asset(icon, color: AppColour.primary),
      ),
      title: Text(title, style: simple_text_style(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
    );
  }
}