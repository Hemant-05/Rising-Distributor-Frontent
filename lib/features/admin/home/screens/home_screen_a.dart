import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/data/services/admin_service.dart';
import 'package:raising_india/data/services/analytics_service.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/review_service.dart';
import 'package:raising_india/features/admin/home/widgets/review_analytics_widget.dart';
import 'package:raising_india/features/admin/home/widgets/sales_dashboard_widget.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/features/admin/order/screens/order_list_screen.dart';
import 'package:raising_india/features/admin/stock_management/screens/low_stock_alert_screen.dart';
import 'package:raising_india/models/dto/dashboard_response.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../comman/simple_text_style.dart';

class HomeScreenA extends StatefulWidget {
  const HomeScreenA({super.key});

  @override
  State<HomeScreenA> createState() => _HomeScreenAState();
}

class _HomeScreenAState extends State<HomeScreenA> with TickerProviderStateMixin {

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewService>().loadAdminReviews();
      context.read<AnalyticsService>().fetchAnalytics();
      context.read<AdminService>().fetchDashboard();
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void navigateToOrderListScreen(String title, OrderFilterType orderType) {
    context.read<AdminService>().loadOrdersByFilterType(orderType);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderListScreen(title: title, orderType: orderType),
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<ReviewService>().loadAdminReviews();
    context.read<AnalyticsService>().fetchAnalytics();
    context.read<AdminService>().fetchDashboard();
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
          child: RefreshIndicator(
            backgroundColor: AppColour.white,
            color: AppColour.primary,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ✅ Order Statistics Section (Upgraded)
                  _buildOrderStatsSection(),

                  // ✅ Low Stock Section
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
      ),
    );
  }

  Widget _buildReviewAnalyticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Icon(Icons.star_rate, color: AppColour.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Review Statistics',
                style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold, color: AppColour.primary),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Icon(Icons.auto_graph, color: AppColour.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Sales Statistics',
                style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold, color: AppColour.primary),
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
            colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<AuthService>(
              builder: (context, authService, _) {
                String name = authService.admin?.name ?? 'Admin';
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
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: SvgPicture.asset(profile_svg, color: Colors.white, width: 28, height: 28),
                        ),
                        const SizedBox(width: 16),

                        // ✅ Enhanced Title Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADMIN DASHBOARD',
                                style: simple_text_style(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Welcome, $name',
                                    style: simple_text_style(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
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
                          Icon(Icons.access_time, color: Colors.white.withOpacity(0.9), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • Business Overview',
                            style: simple_text_style(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
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

  // ===========================================================================
  // 🚀 UPGRADED ORDER STATS SECTION
  // ===========================================================================
  Widget _buildOrderStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section Header ---
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColour.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart_outline, color: AppColour.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Order Pipeline',
                style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold, color: AppColour.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Consumer<AdminService>(
            builder: (context, adminService, _) {
              if (adminService.isLoading) return _buildOrderStatsShimmer();
              if (adminService.dashboardStats == null) return const Center(child: Text('Failed to load statistics'));

              DashboardResponse data = adminService.dashboardStats!;
              final counts = data.orderStatusCounts ?? {};

              // Extract exact statuses based on your backend keys
              int placedCount = counts['PLACED'] ?? 0;
              int confirmedCount = counts['CONFIRMED'] ?? 0;
              int preparingCount = counts['PREPARING'] ?? 0;
              int dispatchCount = counts['DISPATCH'] ?? 0;
              int deliveredCount = counts['DELIVERED'] ?? 0;
              int cancelledCount = counts['CANCELLED'] ?? 0;

              return Column(
                children: [
                  // 1. Global Business Overview Card (Revenue & Total)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TODAY\'S REVENUE', style: simple_text_style(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('₹${data.todayRevenue ?? 0}', style: simple_text_style(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.white30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('TODAY\'S ORDERS', style: simple_text_style(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${data.todayOrdersCount ?? 0}', style: simple_text_style(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. The Detailed Order Pipeline Grid (Compact Cards)
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05, // Makes them slightly rectangular
                    children: [
                      // Note: For navigation, using OrderFilterType.running as a fallback for active orders.
                      // If you add OrderFilterType.placed to your enum later, update it here!
                      _buildCompactStatusCard('NEW (PLACED)', placedCount, Icons.fiber_new_rounded, Colors.blue,
                              () => navigateToOrderListScreen('Newly Placed', OrderFilterType.running)),

                      _buildCompactStatusCard('CONFIRMED', confirmedCount, Icons.thumb_up_alt_outlined, Colors.indigo,
                              () => navigateToOrderListScreen('Confirmed', OrderFilterType.running)),

                      _buildCompactStatusCard('PREPARING', preparingCount, Icons.inventory_2_outlined, Colors.orange,
                              () => navigateToOrderListScreen('Preparing', OrderFilterType.running)),

                      _buildCompactStatusCard('DISPATCH', dispatchCount, Icons.local_shipping_outlined, Colors.purple,
                              () => navigateToOrderListScreen('Dispatched', OrderFilterType.running)),

                      _buildCompactStatusCard('DELIVERED', deliveredCount, Icons.done_all_rounded, Colors.green,
                              () => navigateToOrderListScreen('Delivered', OrderFilterType.all)), // Delivered is usually in "All"

                      _buildCompactStatusCard('CANCELLED', cancelledCount, Icons.cancel_outlined, Colors.red,
                              () => navigateToOrderListScreen('Cancelled', OrderFilterType.cancelled)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- NEW HELPER: Compact Grid Card ---
  Widget _buildCompactStatusCard(String title, int count, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              count.toString(),
              style: simple_text_style(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: simple_text_style(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Shimmer Skeleton Layout ---
  Widget _buildOrderStatsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Top Revenue Card Skeleton
          _buildShimmerBox(height: 90),
          const SizedBox(height: 16),
          // Grid Skeleton (2 rows of 3)
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 100)), const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 100)), const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 100)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 100)), const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 100)), const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    );
  }

  // ===========================================================================
  // LOW STOCK ALERT SECTION
  // ===========================================================================
  Widget _buildLowStockAlertSection() {
    return Consumer<AdminService>(
        builder: (context, adminService, _) {
          if (adminService.isLoading) {
            return const SizedBox(
                height: 100, width: double.infinity,
                child: Center(child: CircularProgressIndicator()));
          }
          if (adminService.dashboardStats != null && (adminService.dashboardStats!.lowStockCount ?? 0) > 0) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red.shade100, Colors.red.shade50]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.shade200, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.warning, color: Colors.red.shade700),
                ),
                title: Text(
                  '${adminService.dashboardStats!.lowStockCount} Low Stock Alert${adminService.dashboardStats!.lowStockCount! > 1 ? 's' : ''}',
                  style: simple_text_style(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                ),
                subtitle: Text('Products need restocking', style: simple_text_style(color: Colors.red.shade600, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.red.shade400, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LowStockAlertScreen())),
              ),
            );
          }
          return const SizedBox.shrink();
        }
    );
  }
}