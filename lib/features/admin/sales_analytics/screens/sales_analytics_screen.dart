/*
// lib/screens/admin/sales_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/sales_analytics/widget/sales_chart_widget.dart';
import 'package:raising_india/models/sales_time_period.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen>
    with TickerProviderStateMixin {

  late TabController _tabController;
  bool _isBarChart = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final period = [
          SalesTimePeriod.day,
          SalesTimePeriod.week,
          SalesTimePeriod.month
        ][_tabController.index];

        context.read<SalesAnalyticsBloc>().add(ChangeSalesTimePeriod(period));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: BlocConsumer<SalesAnalyticsBloc, SalesAnalyticsState>(
        listener: (context, state) {
          if (state is SalesAnalyticsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SalesAnalyticsLoading) {
            return _buildLoadingState();
          } else if (state is SalesAnalyticsLoaded) {
            return _buildLoadedState(state);
          } else if (state is SalesAnalyticsError) {
            return _buildErrorState(state.message);
          }
          return Container();
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
          Text('Sales Analytics',style: simple_text_style(fontSize: 20),),
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
              context.read<SalesAnalyticsBloc>().add(LoadSalesAnalytics());
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

  Widget _buildLoadedState(SalesAnalyticsLoaded state) {
    return RefreshIndicator(
      backgroundColor: AppColour.white,
      color: AppColour.primary,
      onRefresh: () async {
        context.read<SalesAnalyticsBloc>().add(RefreshSalesData());
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Analytics Summary Cards
            _buildSummaryCards(state.currentPeriodStats),
            const SizedBox(height: 24),

            // Main Chart
            SalesChartWidget(
              salesData: state.currentPeriodData,
              period: state.currentPeriod,
              isBarChart: _isBarChart,
            ),
            const SizedBox(height: 24),

            // Insights Section
            _buildInsightsSection(state),
            const SizedBox(height: 24),

            // Performance Metrics
            _buildPerformanceMetrics(state.currentPeriodStats),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(PeriodStatsModel periodStats) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Revenue',
            value: '₹${_formatNumber(periodStats.totalRevenue)}',
            subtitle: periodStats.periodLabel,
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Growth Rate',
            value: '${periodStats.growthPercentage.toStringAsFixed(1)}%',
            subtitle: 'vs previous period',
            icon: periodStats.growthPercentage >= 0
                ? Icons.trending_up
                : Icons.trending_down,
            color: periodStats.growthPercentage >= 0
                ? Colors.green
                : Colors.red,
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
              const Spacer(),
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

  Widget _buildInsightsSection(SalesAnalyticsLoaded state) {
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

          ..._generateInsights(state).map((insight) => Padding(
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

  Widget _buildPerformanceMetrics(PeriodStatsModel periodStats) {
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
                  periodStats.periodLabel, // ✅ Show selected period
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
                  periodStats.totalOrders.toString(),
                  Icons.shopping_cart_outlined,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Avg Order Value',
                  '₹${_formatNumber(periodStats.averageOrderValue)}',
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

  List<String> _generateInsights(SalesAnalyticsLoaded state) {
    final insights = <String>[];
    final periodStats = state.currentPeriodStats; // ✅ Use period-specific stats

    if (periodStats.growthPercentage > 0) {
      insights.add('Sales are growing by ${periodStats.growthPercentage.toStringAsFixed(1)}% compared to the previous ${_getPeriodName(state.currentPeriod)}');
    } else {
      insights.add('Sales decreased by ${periodStats.growthPercentage.abs().toStringAsFixed(1)}% compared to the previous ${_getPeriodName(state.currentPeriod)}');
    }

    if (periodStats.averageOrderValue > 500) {
      insights.add('High average order value indicates strong customer spending for this ${_getPeriodName(state.currentPeriod)}');
    }

    final bestPerformance = state.currentPeriodData.isNotEmpty
        ? state.currentPeriodData.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    if (bestPerformance != null) {
      insights.add('Best performing ${_getPeriodName(state.currentPeriod)} had ₹${_formatNumber(bestPerformance.amount)} in sales');
    }

    return insights;
  }

  String _getPeriodName(SalesTimePeriod period) {
    switch (period) {
      case SalesTimePeriod.day:
        return 'period';
      case SalesTimePeriod.week:
        return 'week';
      case SalesTimePeriod.month:
        return 'month';
    }
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
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
*/
