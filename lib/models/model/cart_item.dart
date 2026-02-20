import 'package:json_annotation/json_annotation.dart';
import 'product.dart'; // Ensure you have this from the previous step

part 'cart_item.g.dart';

@JsonSerializable(explicitToJson: true)
class CartItem {
  final int? id;

  // Cart is ignored to prevent loops

  final Product? product;
  final int? quantity;

  CartItem({
    this.id,
    this.product,
    this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}