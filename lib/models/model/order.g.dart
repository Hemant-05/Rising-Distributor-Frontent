// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num?)?.toInt(),
  razorpayOrderId: json['razorpayOrderId'] as String?,
  userId: json['userId'] as String?,
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  totalPrice: (json['totalPrice'] as num?)?.toDouble(),
  couponCode: json['couponCode'] as String?,
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  status: json['status'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
  payment: json['payment'] == null
      ? null
      : Payment.fromJson(json['payment'] as Map<String, dynamic>),
  orderItems: (json['orderItems'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'razorpayOrderId': instance.razorpayOrderId,
  'userId': instance.userId,
  'address': instance.address?.toJson(),
  'totalPrice': instance.totalPrice,
  'couponCode': instance.couponCode,
  'discountAmount': instance.discountAmount,
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'deliveryFee': instance.deliveryFee,
  'payment': instance.payment?.toJson(),
  'orderItems': instance.orderItems?.map((e) => e.toJson()).toList(),
};
