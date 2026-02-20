import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'wishlist.g.dart';

@JsonSerializable(explicitToJson: true)
class Wishlist {
  final int? id;
  final String? userId;
  final Product? product;
  final DateTime? createdAt;

  Wishlist({
    this.id,
    this.userId,
    this.product,
    this.createdAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) => _$WishlistFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistToJson(this);
}