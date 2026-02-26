import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/analytics_service.dart';
import 'package:raising_india/features/admin/sales_analytics/widget/sales_chart_widget.dart';
import 'package:raising_india/models/model/analytics_response.dart';


class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen>
    with TickerProviderStateMixin {

  late TabController _tabController;
  bool _isBarChart = false;
  AnalyticsFilter _currentFilter = AnalyticsFilter.DAILY;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsService>().fetchAnalytics(_currentFilter);
    });

    // Listen to tab changes to fetch new data
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filter = [
          AnalyticsFilter.DAILY,
          AnalyticsFilter.WEEKLY,
          AnalyticsFilter.MONTHLY,
          AnalyticsFilter.ALL_TIME
        ][_tabController.index];

        setState(() {
          _currentFilter = filter;
        });

        context.read<AnalyticsService>().fetchAnalytics(_currentFilter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Consumer<AnalyticsService>(
        builder: (context, analyticsService, _) {

          if (analyticsService.isLoading) {
            return _buildLoadingState();
          }

          if (analyticsService.error != null && analyticsService.analyticsData == null) {
            return _buildErrorState(analyticsService.error!);
          }

          if (analyticsService.analyticsData != null) {
            return _buildLoadedState(analyticsService.analyticsData!);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      foregroundColor: AppColour.black,
      title: Row(
        children: [
          back_button(),
          const SizedBox(width: 8),
          Text('Sales Analytics', style: simple_text_style(fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isBarChart = !_isBarChart;
            });
          },
          icon: Icon(_isBarChart ? Icons.show_chart : Icons.bar_chart),
          tooltip: _isBarChart ? 'Switch to Line Chart' : 'Switch to Bar Chart',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColour.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColour.primary,
        labelStyle: simple_text_style(),
        tabs: const [
          Tab(text: 'Daily'),
          Tab(text: 'Weekly'),
          Tab(text: 'Monthly'),
          Tab(text: 'ALL TIME',)
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColour.primary),
          const SizedBox(height: 16),
          Text(
            'Loading analytics data...',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: simple_text_style(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AnalyticsService>().fetchAnalytics(_currentFilter);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(AnalyticsResponse data) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: AppColour.primary,
      onRefresh: () async {
        await context.read<AnalyticsService>().fetchAnalytics(_currentFilter);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Analytics Summary Cards
            _buildSummaryCards(data),
            const SizedBox(height: 24),

            // Main Chart
            SalesChartWidget(
              chartData: data.chartData ?? [],
              filter: _currentFilter,
              isBarChart: _isBarChart,
            ),
            const SizedBox(height: 24),

            // Insights Section
            _buildInsightsSection(data),
            const SizedBox(height: 24),

            // Performance Metrics
            _buildPerformanceMetrics(data),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AnalyticsResponse data) {
    final growth = data.revenueGrowthPercentage ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Revenue',
            value: '₹${_formatNumber(data.totalRevenue ?? 0)}',
            subtitle: _getPeriodLabel(),
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Growth Rate',
            value: '${growth.toStringAsFixed(1)}%',
            subtitle: 'vs previous period',
            icon: growth >= 0 ? Icons.trending_up : Icons.trending_down,
            color: growth >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
          const SizedBox(height: 16),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: simple_text_style(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(AnalyticsResponse data) {
    final insights = _generateInsights(data);

    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Sales Insights',
                style: simple_text_style(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: simple_text_style(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(AnalyticsResponse data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Performance Metrics',
                style: simple_text_style(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColour.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPeriodLabel(),
                  style: simple_text_style(
                    color: AppColour.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Total Orders',
                  '${data.totalOrders ?? 0}',
                  Icons.shopping_cart_outlined,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Avg Order Value',
                  '₹${_formatNumber(data.averageOrderValue ?? 0)}',
                  Icons.account_balance_wallet_outlined,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: simple_text_style(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: simple_text_style(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<String> _generateInsights(AnalyticsResponse data) {
    final insights = <String>[];
    final growth = data.revenueGrowthPercentage ?? 0.0;
    final periodName = _getPeriodName();

    if (growth > 0) {
      insights.add('Sales are growing by ${growth.toStringAsFixed(1)}% compared to the previous $periodName');
    } else if (growth < 0) {
      insights.add('Sales decreased by ${growth.abs().toStringAsFixed(1)}% compared to the previous $periodName');
    }

    if ((data.averageOrderValue ?? 0) > 500) {
      insights.add('High average order value indicates strong customer spending for this $periodName');
    }

    if (data.chartData != null && data.chartData!.isNotEmpty) {
      final bestPerformance = data.chartData!.reduce((a, b) => (a.revenue ?? 0) > (b.revenue ?? 0) ? a : b);
      insights.add('Best performing $periodName was ${bestPerformance.label} with ₹${_formatNumber(bestPerformance.revenue ?? 0)} in sales');
    }

    return insights;
  }

  String _getPeriodLabel() {
    switch (_currentFilter) {
      case AnalyticsFilter.DAILY:
        return 'Last 7 Days';
      case AnalyticsFilter.WEEKLY:
        return 'Last 4 Weeks';
      case AnalyticsFilter.MONTHLY:
        return 'Last 12 Months';
      case AnalyticsFilter.ALL_TIME:
        return 'All Time';
    }
  }

  String _getPeriodName() {
    switch (_currentFilter) {
      case AnalyticsFilter.DAILY:
        return 'day';
      case AnalyticsFilter.WEEKLY:
        return 'week';
      case AnalyticsFilter.MONTHLY:
        return 'month';
      case AnalyticsFilter.ALL_TIME:
        return 'period';
    }
  }

  String _formatNumber(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}