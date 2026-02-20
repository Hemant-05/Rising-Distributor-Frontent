import 'package:json_annotation/json_annotation.dart';
import 'chart_data_point.dart'; // Import the new model

part 'analytics_response.g.dart';

@JsonSerializable(explicitToJson: true)
class AnalyticsResponse {
  final double? totalRevenue;
  final int? totalOrders;
  final double? averageOrderValue;
  final double? revenueGrowthPercentage;
  final double? ordersGrowthPercentage;
  final String? timeFilter;

  // NEW FIELD
  final List<ChartDataPoint>? chartData;

  AnalyticsResponse({
    this.totalRevenue,
    this.totalOrders,
    this.averageOrderValue,
    this.revenueGrowthPercentage,
    this.ordersGrowthPercentage,
    this.timeFilter,
    this.chartData,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) => _$AnalyticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsResponseToJson(this);
}