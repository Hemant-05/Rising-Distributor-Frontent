import 'package:json_annotation/json_annotation.dart';

part 'product_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductRequest {
  String? name;
  int? categoryId; // Java Long maps to Dart int
  int? brandId;    // Java Long maps to Dart int
  double? price;   // Java BigDecimal maps to Dart double
  String? description;
  int? quantity;   // Java Integer maps to Dart int
  String? measurement;
  double? mrp;     // Java BigDecimal maps to Dart double
  int? stockQuantity;
  int? lowStockQuantity;
  bool? available;
  bool? discountable;
  List<String>? photosList;
  double? rating;

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