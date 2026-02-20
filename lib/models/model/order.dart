import 'package:json_annotation/json_annotation.dart';
import 'package:raising_india/models/model/payment.dart';
import 'address.dart'; // Ensure you have this model
import 'order_item.dart';

part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  final int? id;
  final String? razorpayOrderId;
  final String? userId;

  final Address? address;

  final double? totalPrice;
  final String? couponCode;
  final double? discountAmount;

  final String? status;
  final DateTime? createdAt;

  final double deliveryFee;
  final Payment? payment;

  final List<OrderItem>? orderItems;

  Order({
    this.id,
    this.razorpayOrderId,
    this.userId,
    this.address,
    this.totalPrice,
    this.couponCode,
    this.discountAmount,
    this.status,
    this.createdAt,
    this.deliveryFee = 0.0,
    this.payment,
    this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}