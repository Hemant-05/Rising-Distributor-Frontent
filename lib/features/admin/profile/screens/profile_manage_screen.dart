import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/banner/bloc/banner_bloc.dart';
import 'package:raising_india/features/admin/banner/screen/all_banner_screen.dart';
import 'package:raising_india/features/admin/category/screens/admin_categories_screen.dart';
import 'package:raising_india/features/admin/profile/screens/admin_profile_screen.dart';
import 'package:raising_india/features/admin/profile/widgets/option_list_tile_widget.dart';
import 'package:raising_india/features/admin/profile/widgets/upper_widget.dart';
import 'package:raising_india/features/admin/review/screens/admin_reviews_screen.dart';
import 'package:raising_india/features/admin/sales_analytics/screens/sales_analytics_screen.dart';
import 'package:raising_india/features/admin/stock_management/screens/low_stock_alert_screen.dart';
import 'package:raising_india/features/auth/bloc/auth_bloc.dart';
import 'package:raising_india/features/auth/screens/signup_screen.dart';

class ProfileManageScreen extends StatefulWidget {
  const ProfileManageScreen({super.key});

  @override
  State<ProfileManageScreen> createState() => _ProfileManageScreenState();
}

class _ProfileManageScreenState extends State<ProfileManageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          upper_widget(50), // Example balance, replace with actual data
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: AppColour.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CusContainer(
                    Column(
                      children: [
                        optionsListTileWidget(
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminProfileScreen(),
                              ),
                            );
                          },
                          profile_svg,
                          'Profile',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                        optionsListTileWidget(
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SalesAnalyticsScreen(),
                              ),
                            );
                          },
                          receipt_svg,
                          'Sale Analytics',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  CusContainer(
                    Column(
                      children: [
                        optionsListTileWidget(
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminCategoriesScreen(),
                              ),
                            );
                          },
                          category_svg,
                          'Categories',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                        optionsListTileWidget(
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminReviewsScreen(),
                              ),
                            );
                          },
                          review_svg,
                          'Reviews',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  CusContainer(
                    Column(
                      children: [
                        optionsListTileWidget(
                          () {
                            BlocProvider.of<BannerBloc>(
                              context,
                            ).add(LoadAllBannerEvent());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AllBannerScreen(),
                              ),
                            );
                          },
                          banner_svg,
                          'Ad Banner',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                        optionsListTileWidget(
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LowStockAlertScreen(),
                              ),
                            );
                          },
                          notification_svg,
                          'Low Stock Alerts',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  CusContainer(
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        return optionsListTileWidget(
                          () {
                            BlocProvider.of<UserBloc>(
                              context,
                            ).add(UserLoggedOut());
                            if (state is UserAuthenticated) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Logged out : ${state.user.name}',
                                  ),
                                ),
                              );
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          logout_svg,
                          'Logout',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget CusContainer(Widget widget) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: widget,
    );
  }
}
