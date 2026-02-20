// lib/widgets/admin/sales_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/analytics_service.dart';
import 'package:raising_india/models/model/chart_data_point.dart'; // Ensure this matches your path

class SalesChartWidget extends StatelessWidget {
  final List<ChartDataPoint> chartData; // CHANGED: Now expects the timeline array
  final AnalyticsFilter filter;
  final bool isBarChart;

  const SalesChartWidget({
    super.key,
    required this.chartData,
    required this.filter,
    this.isBarChart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: isBarChart ? _buildBarChart() : _buildLineChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    switch (filter) {
      case AnalyticsFilter.DAILY:
        title = 'Daily Sales (Last 7 Days)';
        break;
      case AnalyticsFilter.WEEKLY:
        title = 'Weekly Sales (Last 4 Weeks)';
        break;
      case AnalyticsFilter.MONTHLY:
        title = 'Monthly Sales (Last 12 Months)';
        break;
      default:
        title = 'All Time Sales';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColour.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.trending_up,
            color: AppColour.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: simple_text_style(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper to safely calculate Max Y axis
  double _getMaxY() {
    if (chartData.isEmpty) return 0.0;
    return chartData.map((e) => e.revenue ?? 0.0).reduce((a, b) => a > b ? a : b);
  }

  // Helper to safely calculate grid intervals
  double _getSafeInterval(double maxY) {
    double interval = maxY / 5;
    return interval <= 0 ? 1.0 : interval;
  }

  Widget _buildLineChart() {
    if (chartData.isEmpty) return _buildEmptyChart();

    final spots = chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.revenue ?? 0.0);
    }).toList();

    final maxY = _getMaxY();
    final safeMaxY = maxY == 0 ? 100.0 : maxY; // Fallback if no revenue

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getSafeInterval(safeMaxY),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: safeMaxY * 1.1, // Add 10% padding to top
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColour.primary,
                AppColour.primary.withOpacity(0.8),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true), // Show dots to highlight exact days
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColour.primary.withOpacity(0.3),
                  AppColour.primary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index >= 0 && index < chartData.length) {
                  final data = chartData[index];
                  return LineTooltipItem(
                    '${data.label}\n₹${_formatNumber(data.revenue ?? 0)}\n${data.orders ?? 0} orders',
                    simple_text_style(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (chartData.isEmpty) return _buildEmptyChart();

    final barGroups = chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.revenue ?? 0.0,
            gradient: LinearGradient(
              colors: [
                AppColour.primary,
                AppColour.primary.withOpacity(0.7),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    final maxY = _getMaxY();
    final safeMaxY = maxY == 0 ? 100.0 : maxY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: safeMaxY * 1.1,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= 0 && groupIndex < chartData.length) {
                final data = chartData[groupIndex];
                return BarTooltipItem(
                  '${data.label}\n₹${_formatNumber(data.revenue ?? 0)}\n${data.orders ?? 0} orders',
                  simple_text_style(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getSafeInterval(safeMaxY),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  // Extracted titles logic to avoid duplicate code between Line and Bar charts
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            return Text(
              '₹${_formatNumber(value)}',
              style: simple_text_style(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < chartData.length) {
              return Text(
                chartData[index].label ?? '', // Backend now provides "Mon", "Jan", etc.
                style: simple_text_style(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No sales data available',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
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