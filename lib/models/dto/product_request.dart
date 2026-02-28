import 'package:json_annotation/json_annotation.dart';

part 'product_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductRequest {
  final String? name;
  final int? categoryId; // Java Long maps to Dart int
  final int? brandId;    // Java Long maps to Dart int
  final double? price;   // Java BigDecimal maps to Dart double
  final String? description;
  final int? quantity;   // Java Integer maps to Dart int
  final String? measurement;
  final double? mrp;     // Java BigDecimal maps to Dart double
  final int? stockQuantity;
  final int? lowStockQuantity;
  final bool? available;
  final bool? discountable;
  final List<String>? photosList;
  final double? rating;

  ProductRequest({
    this.name,
    this.categoryId,
    this.brandId,
    this.price,
    this.description,
    this.quantity,
    this.measurement,
    this.mrp,
    this.stockQuantity,
    this.lowStockQuantity,
    this.available,
    this.discountable,
    this.photosList,
    this.rating,
  });

  factory ProductRequest.fromJson(Map<String, dynamic> json) =>
      _$ProductRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProductRequestToJson(this);
}