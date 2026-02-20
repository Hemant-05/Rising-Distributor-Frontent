// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  uid: json['uid'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  mobileNumber: json['mobileNumber'] as String?,
  fcmToken: json['fcmToken'] as String?,
  isMobileVerified: json['isMobileVerified'] as bool?,
  password: json['password'] as String?,
  otp: json['otp'] as String?,
  otpExpiryTime: json['otpExpiryTime'] == null
      ? null
      : DateTime.parse(json['otpExpiryTime'] as String),
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'mobileNumber': instance.mobileNumber,
  'fcmToken': instance.fcmToken,
  'isMobileVerified': instance.isMobileVerified,
  'password': instance.password,
  'otp': instance.otp,
  'otpExpiryTime': instance.otpExpiryTime?.toIso8601String(),
};
