import 'package:json_annotation/json_annotation.dart';

part 'product_review.g.dart';

@JsonSerializable()
class ProductReview {
  final int? id;
  final String? userId;
  final String? userName;
  final String? productId;
  final double? rating;
  final String? reviewText;
  final String? productName;
  final String? productImageUrl;
  final String? productBrandName;
  final String? productCategoryName;
  final DateTime? createdAt;

  ProductReview({
    this.id,
    this.userId,
    this.userName,
    this.productId,
    this.rating,
    this.reviewText,
    this.productName,
    this.productImageUrl,
    this.productBrandName,
    this.productCategoryName,
    this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => _$ProductReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ProductReviewToJson(this);
}
