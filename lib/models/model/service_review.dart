import 'package:json_annotation/json_annotation.dart';

part 'service_review.g.dart';

@JsonSerializable()
class ServiceReview {
  final int? id;
  final int? orderId;
  final String? userId;
  final double? rating;
  final String? reviewText;
  final DateTime? createdAt;

  ServiceReview({
    this.id,
    this.orderId,
    this.userId,
    this.rating,
    this.reviewText,
    this.createdAt,
  });

  factory ServiceReview.fromJson(Map<String, dynamic> json) => _$ServiceReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceReviewToJson(this);
}