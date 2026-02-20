// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coupon _$CouponFromJson(Map<String, dynamic> json) => Coupon(
  id: (json['id'] as num?)?.toInt(),
  code: json['code'] as String?,
  discountValue: (json['discountValue'] as num?)?.toDouble(),
  discountType: json['discountType'] as String?,
  minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
  maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
  expirationDate: json['expirationDate'] == null
      ? null
      : DateTime.parse(json['expirationDate'] as String),
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$CouponToJson(Coupon instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'discountValue': instance.discountValue,
  'discountType': instance.discountType,
  'minOrderAmount': instance.minOrderAmount,
  'maxDiscountAmount': instance.maxDiscountAmount,
  'expirationDate': instance.expirationDate?.toIso8601String(),
  'isActive': instance.isActive,
};
