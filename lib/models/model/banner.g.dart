// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Banner _$BannerFromJson(Map<String, dynamic> json) => Banner(
  id: (json['id'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  redirectRoute: json['redirectRoute'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$BannerToJson(Banner instance) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'redirectRoute': instance.redirectRoute,
  'isActive': instance.isActive,
};
