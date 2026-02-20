import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/home/screens/home_screen_u.dart';
import 'package:raising_india/features/user/notification/screens/notification_screen.dart';

import 'profile/screens/profile_screen.dart';

class MainScreenU extends StatefulWidget {
  const MainScreenU({super.key});

  @override
  State<MainScreenU> createState() => _MainScreenUState();
}

class _MainScreenUState extends State<MainScreenU> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );
  int currentIndex = 0;

  List<Widget> pages = [
    const HomeScreenU(),
    const CartScreen(),
    const NotificationsScreen(userId: ''),
    const ProfileScreen(),
  ];
  final NavBarStyle _navBarStyle = NavBarStyle.style12;

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          home_svg,
          color: currentIndex == 0 ? AppColour.primary : AppColour.grey,
        ),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          cart_svg,
          color: currentIndex == 1 ? AppColour.primary : AppColour.grey,
        ),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          notification_svg,
          color: currentIndex == 2 ? AppColour.primary : AppColour.grey,
        ),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          profile_svg,
          color: currentIndex == 3 ? AppColour.primary : AppColour.grey,
        ),
        title: '',
        activeColorPrimary: AppColour.primary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      onItemSelected: (value) => setState(() {
        currentIndex = value;
      }),
      backgroundColor: AppColour.white,
      screens: pages,
      hideNavigationBarWhenKeyboardAppears: true,

      items: _navBarsItems(),
      controller: _controller,
      navBarStyle: _navBarStyle,
      stateManagement: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: 30,
      isVisible: true,
    );
  }
}
