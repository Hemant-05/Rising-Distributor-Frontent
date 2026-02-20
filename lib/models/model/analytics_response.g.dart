// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsResponse _$AnalyticsResponseFromJson(Map<String, dynamic> json) =>
    AnalyticsResponse(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
      totalOrders: (json['totalOrders'] as num?)?.toInt(),
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble(),
      revenueGrowthPercentage: (json['revenueGrowthPercentage'] as num?)
          ?.toDouble(),
      ordersGrowthPercentage: (json['ordersGrowthPercentage'] as num?)
          ?.toDouble(),
      timeFilter: json['timeFilter'] as String?,
      chartData: (json['chartData'] as List<dynamic>?)
          ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalyticsResponseToJson(AnalyticsResponse instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'totalOrders': instance.totalOrders,
      'averageOrderValue': instance.averageOrderValue,
      'revenueGrowthPercentage': instance.revenueGrowthPercentage,
      'ordersGrowthPercentage': instance.ordersGrowthPercentage,
      'timeFilter': instance.timeFilter,
      'chartData': instance.chartData?.map((e) => e.toJson()).toList(),
    };
