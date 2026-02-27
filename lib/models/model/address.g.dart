// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  id: (json['id'] as num?)?.toInt(),
  userId: json['userId'] as String?,
  title: json['title'] as String?,
  recipientName: json['recipientName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  streetAddress: json['streetAddress'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  zipCode: json['zipCode'] as String?,
  primary: json['primary'] as bool?,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'recipientName': instance.recipientName,
  'phoneNumber': instance.phoneNumber,
  'streetAddress': instance.streetAddress,
  'city': instance.city,
  'state': instance.state,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'zipCode': instance.zipCode,
  'primary': instance.primary,
};
