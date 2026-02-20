// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: (json['id'] as num?)?.toInt(),
  product: json['product'] == null
      ? null
      : Product.fromJson(json['product'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt(),
  orderedPrice: (json['orderedPrice'] as num?)?.toDouble(),
  isDiscountable: json['isDiscountable'] as bool?,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'product': instance.product?.toJson(),
  'quantity': instance.quantity,
  'orderedPrice': instance.orderedPrice,
  'isDiscountable': instance.isDiscountable,
};
