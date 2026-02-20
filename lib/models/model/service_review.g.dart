// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceReview _$ServiceReviewFromJson(Map<String, dynamic> json) =>
    ServiceReview(
      id: (json['id'] as num?)?.toInt(),
      orderId: (json['orderId'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewText: json['reviewText'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ServiceReviewToJson(ServiceReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'userId': instance.userId,
      'rating': instance.rating,
      'reviewText': instance.reviewText,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
