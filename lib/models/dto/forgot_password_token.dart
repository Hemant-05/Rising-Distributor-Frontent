import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_token.g.dart';

@JsonSerializable()
class ForgotPasswordToken {
  final int? id;
  final String? email;
  final String? otp;
  final DateTime? expirationTime;

  ForgotPasswordToken({
    this.id,
    this.email,
    this.otp,
    this.expirationTime,
  });

  factory ForgotPasswordToken.fromJson(Map<String, dynamic> json) => _$ForgotPasswordTokenFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordTokenToJson(this);
}