// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductReview _$ProductReviewFromJson(Map<String, dynamic> json) =>
    ProductReview(
      id: (json['id'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      productId: (json['productId'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewText: json['reviewText'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProductReviewToJson(ProductReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'productId': instance.productId,
      'rating': instance.rating,
      'reviewText': instance.reviewText,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
