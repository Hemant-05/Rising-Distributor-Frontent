import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/home/bloc/order_cubit/order_stats_cubit.dart';
import 'package:raising_india/features/admin/home/widgets/review_analytics_widget.dart';
import 'package:raising_india/features/admin/home/widgets/sales_dashboard_widget.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/features/admin/order/screens/order_list_screen.dart';
import 'package:raising_india/features/admin/review/bloc/admin_review_bloc.dart';
import 'package:raising_india/features/admin/sales_analytics/bloc/sales_analytics_bloc.dart';
import 'package:raising_india/features/admin/stock_management/screens/low_stock_alert_screen.dart';
import '../../../../comman/simple_text_style.dart';
import '../../../auth/bloc/auth_bloc.dart';

class HomeScreenA extends StatefulWidget {
  const HomeScreenA({super.key});

  @override
  State<HomeScreenA> createState() => _HomeScreenAState();
}

class _HomeScreenAState extends State<HomeScreenA>
    with TickerProviderStateMixin {

  // ✅ Animation Controllers for stunning animations
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();

    // Load data
    context.read<AdminReviewBloc>().add(LoadAllReviews());
    context.read<SalesAnalyticsBloc>().add(LoadSalesAnalytics());
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void navigateToOrderListScreen(String title, OrderFilterType orderType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderListScreen(title: title, orderType: orderType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildStunningAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ✅ Order Statistics Section
                _buildOrderStatsSection(),

                _buildLowStockAlertSection(),

                // ✅ Sales Analytics Section
                _buildSalesAnalyticsSection(),
                const SizedBox(height: 20),

                // ✅ Review Analytics Section
                _buildReviewAnalyticsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildReviewAnalyticsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColour.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: AppColour.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Review Statistics',
                style: simple_text_style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColour.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ReviewAnalyticsWidget(),
        ],
      ),
    );
  }
  
  Widget _buildSalesAnalyticsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColour.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: AppColour.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sales Statistics',
                style: simple_text_style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColour.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SalesDashboardWidget(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildStunningAppBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 150),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColour.primary,
              AppColour.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                String name = '';
                if (state is UserAuthenticated) {
                  name = state.user.name;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        // ✅ Enhanced Profile Avatar
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: SvgPicture.asset(
                            profile_svg,
                            color: Colors.white,
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ✅ Enhanced Title Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADMIN DASHBOARD',
                                style: simple_text_style(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Welcome, $name',
                                    style: simple_text_style(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ✅ Current Time & Date
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • Business Overview',
                            style: simple_text_style(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColour.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: AppColour.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Order Statistics',
                style: simple_text_style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColour.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Cards
          BlocBuilder<OrderStatsCubit, OrderStatsState>(
            builder: (context, state) {
              return Column(
                children: [
                  // First Row - Running & Today's Orders
                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedStatsCard(
                          title: 'RUNNING',
                          value: state.runningOrders.toString(),
                          icon: Icons.local_shipping,
                          color: AppColour.primary,
                          onTap: () => navigateToOrderListScreen('Running', OrderFilterType.running),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedStatsCard(
                          title: 'TODAY\'S',
                          value: state.todayOrders.toString(),
                          icon: Icons.today,
                          color: Colors.blue,
                          onTap: () => navigateToOrderListScreen('Today', OrderFilterType.today),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Second Row - Delivered & Cancelled Orders
                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedStatsCard(
                          title: 'DELIVERED',
                          value: state.deliveredOrders.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                          onTap: () => navigateToOrderListScreen('Delivered', OrderFilterType.delivered),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedStatsCard(
                          title: 'CANCELLED',
                          value: state.cancelledOrders.toString(),
                          icon: Icons.cancel,
                          color: Colors.red,
                          onTap: () => navigateToOrderListScreen('Cancelled', OrderFilterType.cancelled),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Third Row - Total Orders (Full Width)
                  _buildEnhancedStatsCard(
                    title: 'ALL ORDERS',
                    value: state.totalOrders.toString(),
                    icon: Icons.inventory_2,
                    color: Colors.purple,
                    onTap: () => navigateToOrderListScreen('All', OrderFilterType.all),
                    isFullWidth: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isFullWidth
            ? Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: simple_text_style(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: simple_text_style(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Total orders in system',
                    style: simple_text_style(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        )
            : Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 12),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: simple_text_style(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: simple_text_style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              'Orders',
              style: simple_text_style(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLowStockAlertSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('low_stock_alerts')
          .where('isResolved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final alertCount = snapshot.data!.docs.length;
        if (alertCount == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade100, Colors.red.shade50],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning, color: Colors.red.shade700),
            ),
            title: Text(
              '$alertCount Low Stock Alert${alertCount > 1 ? 's' : ''}',
              style: simple_text_style(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            subtitle: Text(
              'Products need restocking',
              style: simple_text_style(color: Colors.red.shade600, fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.red.shade400),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LowStockAlertScreen()),
            ),
          ),
        );
      },
    );
  }

}
