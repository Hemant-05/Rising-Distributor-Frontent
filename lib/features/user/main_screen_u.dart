import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

// UI & Constants
import 'package:raising_india/comman/floating_cart_banner.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';

// Screens
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/home/screens/home_screen_u.dart';
import 'package:raising_india/features/user/categories/screens/all_categories_screen.dart'; // ✅ Added Categories Screen
import 'package:raising_india/features/user/order/screens/order_screen.dart';
import 'package:raising_india/features/user/notification/screens/notification_screen.dart';
import 'profile/screens/profile_screen.dart';

class MainScreenU extends StatefulWidget {
  const MainScreenU({super.key});

  @override
  State<MainScreenU> createState() => _MainScreenUState();
}

class _MainScreenUState extends State<MainScreenU> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  int currentIndex = 0;

  // ✅ Added AllCategoriesScreen as the 2nd tab
  List<Widget> get _pages => [
    _buildWrappedScreen(const HomeScreenU()),
    _buildWrappedScreen(const AllCategoriesScreen()),
    _buildWrappedScreen(const OrderScreen()),
    _buildWrappedScreen(const NotificationsScreen()),
    _buildWrappedScreen(const ProfileScreen()),
  ];

  // The Magic Wrapper: Forces the cart banner to sit exactly above the Nav Bar
  Widget _buildWrappedScreen(Widget screen) {
    return Column(
      children: [
        Expanded(child: screen),
        FloatingCartBanner(
          onCartTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
          },
        ),
      ],
    );
  }

  // ✅ Switched to style3: Standard E-commerce look (Icon + Text stacked)
  final NavBarStyle _navBarStyle = NavBarStyle.style3;

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4), // ✅ Nudges the icon down closer to the text
          child: SvgPicture.asset(home_svg, color: currentIndex == 0 ? AppColour.primary : AppColour.grey, width: 22),
        ),
        title: 'Home',
        activeColorPrimary: AppColour.primary,
        inactiveColorPrimary: AppColour.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4),
          child: SvgPicture.asset(category_svg, color: currentIndex == 1 ? AppColour.primary : AppColour.grey, width: 24),
        ),
        title: 'Categories',
        activeColorPrimary: AppColour.primary,
        inactiveColorPrimary: AppColour.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4),
          child: SvgPicture.asset(order_icon_svg, color: currentIndex == 2 ? AppColour.primary : AppColour.grey, width: 22),
        ),
        title: 'Orders',
        activeColorPrimary: AppColour.primary,
        inactiveColorPrimary: AppColour.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4),
          child: SvgPicture.asset(notification_svg, color: currentIndex == 3 ? AppColour.primary : AppColour.grey, width: 22),
        ),
        title: 'Alerts',
        activeColorPrimary: AppColour.primary,
        inactiveColorPrimary: AppColour.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4),
          child: SvgPicture.asset(profile_svg, color: currentIndex == 4 ? AppColour.primary : AppColour.grey, width: 22),
        ),
        title: 'Profile',
        activeColorPrimary: AppColour.primary,
        inactiveColorPrimary: AppColour.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      onItemSelected: (value) => setState(() => currentIndex = value),
      backgroundColor: AppColour.white,
      screens: _pages,
      hideNavigationBarWhenKeyboardAppears: true,
      items: _navBarsItems(),
      controller: _controller,
      navBarStyle: _navBarStyle,
      stateManagement: true,

      // ✅ Added top shadow to separate the nav bar from the content
      decoration: NavBarDecoration(
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),

      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(duration: Duration(milliseconds: 200), curve: Curves.easeInOut),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: false, // Turned off for instant, snappy tab switching (Zepto/Swiggy style)
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: 65, // Slightly taller to comfortably fit both icon and text
      isVisible: true,
    );
  }
}