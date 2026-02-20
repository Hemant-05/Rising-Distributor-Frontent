// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_order_review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminOrderReviewDto _$AdminOrderReviewDtoFromJson(Map<String, dynamic> json) =>
    AdminOrderReviewDto(
      serviceReview: json['serviceReview'] == null
          ? null
          : ServiceReview.fromJson(
              json['serviceReview'] as Map<String, dynamic>,
            ),
      productReviews: (json['productReviews'] as List<dynamic>?)
          ?.map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdminOrderReviewDtoToJson(
  AdminOrderReviewDto instance,
) => <String, dynamic>{
  'serviceReview': instance.serviceReview?.toJson(),
  'productReviews': instance.productReviews?.map((e) => e.toJson()).toList(),
};
