import 'package:json_annotation/json_annotation.dart';

part 'coupon.g.dart';

@JsonSerializable()
class Coupon {
  final int? id;
  final String? code;
  final double? discountValue;
  final String? discountType;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? expirationDate;
  final bool? isActive;

  Coupon({
    this.id,
    this.code,
    this.discountValue,
    this.discountType,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.expirationDate,
    this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);
  Map<String, dynamic> toJson() => _$CouponToJson(this);
}