import 'package:json_annotation/json_annotation.dart';
import 'cart_item.dart';

part 'cart.g.dart';

@JsonSerializable(explicitToJson: true)
class Cart {
  final int? id;
  final String? userId;

  // Maps to "items" in Java
  final List<CartItem>? items;

  final String? appliedCouponCode;
  final double? discountAmount;
  final double? totalPrice;

  Cart({
    this.id,
    this.userId,
    this.items,
    this.appliedCouponCode,
    this.discountAmount,
    this.totalPrice,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}