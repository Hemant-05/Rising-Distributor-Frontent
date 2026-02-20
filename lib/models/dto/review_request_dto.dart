import 'package:json_annotation/json_annotation.dart';

part 'review_request_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewRequestDto {
  final int? orderId;
  final String? userId;
  final String? userName;

  // Service Rating
  final double? serviceRating;
  final String? serviceReview;

  // Product Ratings List
  final List<ProductRatingDto>? products;

  ReviewRequestDto({
    this.orderId,
    this.userId,
    this.userName,
    this.serviceRating,
    this.serviceReview,
    this.products,
  });

  factory ReviewRequestDto.fromJson(Map<String, dynamic> json) => _$ReviewRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewRequestDtoToJson(this);
}

// Nested Class mapped as a standalone Dart class
@JsonSerializable()
class ProductRatingDto {
  final int? productId;
  final double? rating;
  final String? reviewText;

  ProductRatingDto({this.productId, this.rating, this.reviewText});

  factory ProductRatingDto.fromJson(Map<String, dynamic> json) => _$ProductRatingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductRatingDtoToJson(this);
}