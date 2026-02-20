// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewRequestDto _$ReviewRequestDtoFromJson(Map<String, dynamic> json) =>
    ReviewRequestDto(
      orderId: (json['orderId'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      serviceRating: (json['serviceRating'] as num?)?.toDouble(),
      serviceReview: json['serviceReview'] as String?,
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => ProductRatingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReviewRequestDtoToJson(ReviewRequestDto instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'userId': instance.userId,
      'userName': instance.userName,
      'serviceRating': instance.serviceRating,
      'serviceReview': instance.serviceReview,
      'products': instance.products?.map((e) => e.toJson()).toList(),
    };

ProductRatingDto _$ProductRatingDtoFromJson(Map<String, dynamic> json) =>
    ProductRatingDto(
      productId: (json['productId'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewText: json['reviewText'] as String?,
    );

Map<String, dynamic> _$ProductRatingDtoToJson(ProductRatingDto instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'rating': instance.rating,
      'reviewText': instance.reviewText,
    };
