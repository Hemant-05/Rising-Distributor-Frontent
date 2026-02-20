import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int? id;
  // Order is ignored via @JsonIgnore in Java

  final String? paymentMethod;
  final String? paymentStatus;
  final String? transactionId;
  final DateTime? paymentDate;

  Payment({
    this.id,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionId,
    this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}