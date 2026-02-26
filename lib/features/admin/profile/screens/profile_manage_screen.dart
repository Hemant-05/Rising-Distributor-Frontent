import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/banner_service.dart';
import 'package:raising_india/features/admin/banner/screen/all_banner_screen.dart';
import 'package:raising_india/features/admin/brand/admin_brand_screen.dart';
import 'package:raising_india/features/admin/category/screens/admin_categories_screen.dart';
import 'package:raising_india/features/admin/profile/screens/admin_profile_screen.dart';
import 'package:raising_india/features/admin/profile/widgets/option_list_tile_widget.dart';
import 'package:raising_india/features/admin/profile/widgets/upper_widget.dart';
import 'package:raising_india/features/admin/review/screens/admin_reviews_screen.dart';
import 'package:raising_india/features/admin/sales_analytics/screens/sales_analytics_screen.dart';
import 'package:raising_india/features/admin/stock_management/screens/low_stock_alert_screen.dart';
import 'package:raising_india/features/auth/screens/login_screen.dart';
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
      appBar: _buildStunningAppBar(),
      body: Column(
        children: [
          // upper_widget(50), // Example balance, replace with actual data
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: AppColour.white),
              child: SingleChildScrollView(
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
                                  builder: (_) => const AdminBrandScreen(),
                                ),
                              );
                            },
                            category_svg,
                            'Brands',
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
                              context.read<BannerService>().loadAdminBanners();
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildStunningAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Management',
                  style: simple_text_style(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Manage your profile & entire system',
                  style: simple_text_style(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
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
