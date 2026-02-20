import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String? uid;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? fcmToken;
  final bool? isMobileVerified;

  // Note: Password usually isn't sent back in JSON, but kept for matching Java
  final String? password;
  final String? otp;
  final DateTime? otpExpiryTime;

  Customer({
    this.uid,
    this.name,
    this.email,
    this.mobileNumber,
    this.fcmToken,
    this.isMobileVerified,
    this.password,
    this.otp,
    this.otpExpiryTime,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}