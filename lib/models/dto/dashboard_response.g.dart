// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble(),
      totalOrders: (json['totalOrders'] as num?)?.toInt(),
      orderStatusCounts: (json['orderStatusCounts'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toInt())),
      lowStockCount: (json['lowStockCount'] as num?)?.toInt(),
      lowStockProducts: (json['lowStockProducts'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUsers: (json['totalUsers'] as num?)?.toInt(),
      recentOrders: (json['recentOrders'] as List<dynamic>?)
          ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'todayRevenue': instance.todayRevenue,
      'totalOrders': instance.totalOrders,
      'orderStatusCounts': instance.orderStatusCounts,
      'lowStockCount': instance.lowStockCount,
      'lowStockProducts': instance.lowStockProducts
          ?.map((e) => e.toJson())
          .toList(),
      'totalUsers': instance.totalUsers,
      'recentOrders': instance.recentOrders?.map((e) => e.toJson()).toList(),
    };
