import 'package:json_annotation/json_annotation.dart';
import 'package:raising_india/models/model/order.dart';
import 'package:raising_india/models/model/product.dart';

part 'dashboard_response.g.dart';

@JsonSerializable(explicitToJson: true)
class DashboardResponse {
  // 1. Financial Stats
  final double? totalRevenue;
  final double? todayRevenue;
  final int? totalOrders;

  // 2. Order Breakdown (Map<String, Long> -> Map<String, int>)
  final Map<String, int>? orderStatusCounts;

  // 3. Inventory Health
  final int? lowStockCount;
  final List<Product>? lowStockProducts;

  // 4. Customer Stats
  final int? totalUsers;

  // 5. Recent Activity
  final List<Order>? recentOrders;

  DashboardResponse({
    this.totalRevenue,
    this.todayRevenue,
    this.totalOrders,
    this.orderStatusCounts,
    this.lowStockCount,
    this.lowStockProducts,
    this.totalUsers,
    this.recentOrders,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) => _$DashboardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);
}