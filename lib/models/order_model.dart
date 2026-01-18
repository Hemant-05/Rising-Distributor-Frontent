import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/models/address_model.dart';
import 'package:raising_india/models/product_model.dart';

import '../constant/ConString.dart';
class OrderModel {
  final String orderId; // Unique order ID
  final String? name;
  final String userId; // Firebase UID
  final DateTime createdAt;
  final DateTime? scheduledTime; // For scheduled deliveries
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod; // 'prepaid' or 'cod'
  final String paymentStatus; // 'pending', 'paid', 'failed', 'refunded'
  final String orderStatus; // 'created', 'confirmed', 'preparing', 'dispatched', 'delivered', 'cancelled'
  final AddressModel address;
  final String? transactionId; // For prepaid orders
  final String? cancellationReason;
  final DateTime? deliveredAt;
  final DateTime? paidAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.createdAt,
    this.scheduledTime,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.address,
    this.transactionId,
    this.cancellationReason,
    this.deliveredAt,
    this.paidAt,
    this.name,
  });
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledTime': scheduledTime != null
          ? Timestamp.fromDate(scheduledTime!)
          : null,
      'items': items, // List<Map> is already Firestore-compatible
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'address': address.toJson(), // Convert DeliveryAddress to Map
      'transactionId': transactionId,
      'cancellationReason': cancellationReason,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }

  // Create OrderModel from Firestore Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      scheduledTime: map['scheduledTime'] != null
          ? (map['scheduledTime'] as Timestamp).toDate()
          : null,
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] as num).toDouble(),
      deliveryFee: (map['deliveryFee'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['paymentMethod'],
      paymentStatus: map['paymentStatus'] ?? PayStatusPending,
      orderStatus: map['orderStatus'] ?? OrderStatusCreated,
      address: AddressModel.fromMap(
        Map<String, dynamic>.from(map['address'] ?? {}),
      ),
      transactionId: map['transactionId'],
      cancellationReason: map['cancellationReason'],
      deliveredAt: map['deliveredAt'] != null
          ? (map['deliveredAt'] as Timestamp).toDate()
          : null,
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
    );
  }
}
