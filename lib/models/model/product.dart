import 'package:json_annotation/json_annotation.dart';
import 'category.dart'; // Create this if missing
import 'brand.dart';    // Create this if missing

part 'product.g.dart';

@JsonSerializable(explicitToJson: true)
class Product {
  final String? pid;
  final String? uid;
  final String? name;
  final String? nameLower;
  final double? rating;

  final Category? category;
  final Brand? brand;

  final String? description;
  final double? price;
  final int? quantity;
  final String? measurement;

  final bool? isDiscountable;
  final double? mrp;
  final int? stockQuantity;
  final int? lowStockQuantity;

  final DateTime? lastStockUpdate;
  final bool? isAvailable;

  final List<String>? photosList;

  Product({
    this.pid,
    this.uid,
    this.name,
    this.nameLower,
    this.rating,
    this.category,
    this.brand,
    this.description,
    this.price,
    this.quantity,
    this.measurement,
    this.isDiscountable,
    this.mrp,
    this.stockQuantity,
    this.lowStockQuantity,
    this.lastStockUpdate,
    this.isAvailable,
    this.photosList,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}