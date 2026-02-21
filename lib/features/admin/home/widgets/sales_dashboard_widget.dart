import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/analytics_service.dart';
import 'package:raising_india/features/admin/home/widgets/sales_dashboard_shimmer.dart';
import 'package:raising_india/features/admin/sales_analytics/widget/sales_chart_widget.dart';
import 'package:raising_india/models/model/analytics_response.dart';

class SalesDashboardWidget extends StatelessWidget {
  const SalesDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsService>(
      builder: (context,analyticService, _) {
        if (analyticService.isLoading) {
          return SalesDashboardShimmer();
        } else if (!analyticService.isLoading && analyticService.analyticsData != null) {
          return _buildLoadedWidget(analyticService.analyticsData!, analyticService);
        } else if (analyticService.error != null) {
          return _buildErrorWidget(analyticService.error!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColour.primary),
            const SizedBox(height: 16),
            Text(
              'Loading sales data...',
              style: simple_text_style(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading sales data',
              style: simple_text_style(
                color: Colors.red.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: simple_text_style(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedWidget(AnalyticsResponse response, AnalyticsService service) {
    return Column(
      children: [
        _buildPeriodSelector(response,service),
        SizedBox(height: 8,),

        // Stats Cards
        _buildStatsRow(response),
        const SizedBox(height: 20),

        // Chart with Period Selector
        _buildChartSection(response,service),
      ],
    );
  }

  Widget _buildStatsRow(AnalyticsResponse response) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Revenue',
                value: '₹${_formatNumber(response.totalRevenue!)}',
                icon: Icons.attach_money,
                color: Colors.green,
                subtitle: response.timeFilter!,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Orders',
                value: response.totalOrders.toString(),
                icon: Icons.shopping_cart,
                color: Colors.blue,
                subtitle: response.timeFilter!,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Avg Order Value',
                value: '₹${_formatNumber(response.averageOrderValue!)}',
                icon: Icons.trending_up,
                color: Colors.orange,
                subtitle: 'Per order',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Growth',
                value: '${response.revenueGrowthPercentage!.toStringAsFixed(1)}%',
                icon: response.revenueGrowthPercentage! >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: response.revenueGrowthPercentage! >= 0 ? Colors.green : Colors.red,
                subtitle: 'vs previous period',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
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
          const SizedBox(height: 12),
          Text(
            value,
            style: simple_text_style(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: simple_text_style(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            subtitle,
            style: simple_text_style(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(AnalyticsResponse response, AnalyticsService service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
            child: Text(
              'Sales Overview',
              style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Chart
          SalesChartWidget(
            chartData: response.chartData!,
            filter: service.currentFilter,
            isBarChart: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AnalyticsResponse response,AnalyticsService service) {
    return Container(
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _buildPeriodButton('Day', AnalyticsFilter.DAILY, service.currentFilter),
          const SizedBox(width: 8),
          _buildPeriodButton('Week', AnalyticsFilter.WEEKLY,service.currentFilter),
          const SizedBox(width: 8),
          _buildPeriodButton('Month', AnalyticsFilter.MONTHLY,service.currentFilter),
          const SizedBox(width: 8),
          _buildPeriodButton('All', AnalyticsFilter.ALL_TIME,service.currentFilter),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    String label,
    AnalyticsFilter filter,
    AnalyticsFilter currentPeriod,
  ) {
    final isSelected = filter == currentPeriod;

    return Consumer<AnalyticsService>(
      builder: (context, analyticService, _) {
        return GestureDetector(
          onTap: () {
            context.read<AnalyticsService>().fetchAnalytics(filter);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColour.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColour.primary : Colors.grey.shade300,
              ),
            ),
            child: Text(
              label,
              style: simple_text_style(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
