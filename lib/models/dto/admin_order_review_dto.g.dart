// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_order_review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderReviewDto _$OrderReviewDtoFromJson(Map<String, dynamic> json) =>
    OrderReviewDto(
      serviceReview: json['serviceReview'] == null
          ? null
          : ServiceReview.fromJson(
              json['serviceReview'] as Map<String, dynamic>,
            ),
      productReviews: (json['productReviews'] as List<dynamic>?)
          ?.map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderReviewDtoToJson(
  OrderReviewDto instance,
) => <String, dynamic>{
  'serviceReview': instance.serviceReview?.toJson(),
  'productReviews': instance.productReviews?.map((e) => e.toJson()).toList(),
};
