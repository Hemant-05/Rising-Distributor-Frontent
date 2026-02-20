// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cart _$CartFromJson(Map<String, dynamic> json) => Cart(
  id: (json['id'] as num?)?.toInt(),
  userId: json['userId'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  appliedCouponCode: json['appliedCouponCode'] as String?,
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  totalPrice: (json['totalPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'appliedCouponCode': instance.appliedCouponCode,
  'discountAmount': instance.discountAmount,
  'totalPrice': instance.totalPrice,
};
