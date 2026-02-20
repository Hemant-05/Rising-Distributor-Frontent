// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  parentCategory: json['parentCategory'] == null
      ? null
      : Category.fromJson(json['parentCategory'] as Map<String, dynamic>),
  subCategories: (json['subCategories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'parentCategory': instance.parentCategory?.toJson(),
  'subCategories': instance.subCategories?.map((e) => e.toJson()).toList(),
};
