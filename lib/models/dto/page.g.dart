// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page<T> _$PageFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => Page<T>(
  content: (json['content'] as List<dynamic>?)?.map(fromJsonT).toList(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  totalElements: (json['totalElements'] as num?)?.toInt(),
  last: json['last'] as bool?,
  size: (json['size'] as num?)?.toInt(),
  number: (json['number'] as num?)?.toInt(),
);

Map<String, dynamic> _$PageToJson<T>(
  Page<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'content': instance.content?.map(toJsonT).toList(),
  'totalPages': instance.totalPages,
  'totalElements': instance.totalElements,
  'last': instance.last,
  'size': instance.size,
  'number': instance.number,
};
