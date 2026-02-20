// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogInRequest _$LogInRequestFromJson(Map<String, dynamic> json) => LogInRequest(
  email: json['email'] as String?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$LogInRequestToJson(LogInRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RegistrationRequest _$RegistrationRequestFromJson(Map<String, dynamic> json) =>
    RegistrationRequest(
      name: json['name'] as String?,
      email: json['email'] as String?,
      number: json['number'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$RegistrationRequestToJson(
  RegistrationRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'number': instance.number,
  'password': instance.password,
};

MobileRequest _$MobileRequestFromJson(Map<String, dynamic> json) =>
    MobileRequest(mobileNumber: json['mobileNumber'] as String?);

Map<String, dynamic> _$MobileRequestToJson(MobileRequest instance) =>
    <String, dynamic>{'mobileNumber': instance.mobileNumber};

OtpVerificationRequest _$OtpVerificationRequestFromJson(
  Map<String, dynamic> json,
) => OtpVerificationRequest(otp: json['otp'] as String?);

Map<String, dynamic> _$OtpVerificationRequestToJson(
  OtpVerificationRequest instance,
) => <String, dynamic>{'otp': instance.otp};
