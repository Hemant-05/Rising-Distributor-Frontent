// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartDataPoint _$ChartDataPointFromJson(Map<String, dynamic> json) =>
    ChartDataPoint(
      label: json['label'] as String?,
      revenue: (json['revenue'] as num?)?.toDouble(),
      orders: (json['orders'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChartDataPointToJson(ChartDataPoint instance) =>
    <String, dynamic>{
      'label': instance.label,
      'revenue': instance.revenue,
      'orders': instance.orders,
    };
