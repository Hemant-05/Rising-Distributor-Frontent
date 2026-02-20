// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordToken _$ForgotPasswordTokenFromJson(Map<String, dynamic> json) =>
    ForgotPasswordToken(
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String?,
      otp: json['otp'] as String?,
      expirationTime: json['expirationTime'] == null
          ? null
          : DateTime.parse(json['expirationTime'] as String),
    );

Map<String, dynamic> _$ForgotPasswordTokenToJson(
  ForgotPasswordToken instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'otp': instance.otp,
  'expirationTime': instance.expirationTime?.toIso8601String(),
};
