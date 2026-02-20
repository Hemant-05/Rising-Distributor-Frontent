import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'order_item.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderItem {
  final int? id;

  // 'order' is ignored in Java JSON, so we skip it here to avoid loops

  final Product? product;
  final int? quantity;
  final double? orderedPrice;
  final bool? isDiscountable;

  OrderItem({
    this.id,
    this.product,
    this.quantity,
    this.orderedPrice,
    this.isDiscountable,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}