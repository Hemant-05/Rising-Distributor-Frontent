import 'package:json_annotation/json_annotation.dart';
import 'package:raising_india/models/model/product_review.dart';
import 'package:raising_india/models/model/service_review.dart';

part 'admin_order_review_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AdminOrderReviewDto {
  final ServiceReview? serviceReview;
  final List<ProductReview>? productReviews;

  AdminOrderReviewDto({
    this.serviceReview,
    this.productReviews,
  });

  factory AdminOrderReviewDto.fromJson(Map<String, dynamic> json) =>
      _$AdminOrderReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AdminOrderReviewDtoToJson(this);
}