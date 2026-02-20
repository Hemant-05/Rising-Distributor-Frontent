// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  pid: json['pid'] as String?,
  uid: json['uid'] as String?,
  name: json['name'] as String?,
  nameLower: json['nameLower'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  brand: json['brand'] == null
      ? null
      : Brand.fromJson(json['brand'] as Map<String, dynamic>),
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  quantity: (json['quantity'] as num?)?.toInt(),
  measurement: json['measurement'] as String?,
  isDiscountable: json['isDiscountable'] as bool?,
  mrp: (json['mrp'] as num?)?.toDouble(),
  stockQuantity: (json['stockQuantity'] as num?)?.toInt(),
  lowStockQuantity: (json['lowStockQuantity'] as num?)?.toInt(),
  lastStockUpdate: json['lastStockUpdate'] == null
      ? null
      : DateTime.parse(json['lastStockUpdate'] as String),
  isAvailable: json['isAvailable'] as bool?,
  photosList: (json['photosList'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'pid': instance.pid,
  'uid': instance.uid,
  'name': instance.name,
  'nameLower': instance.nameLower,
  'rating': instance.rating,
  'category': instance.category?.toJson(),
  'brand': instance.brand?.toJson(),
  'description': instance.description,
  'price': instance.price,
  'quantity': instance.quantity,
  'measurement': instance.measurement,
  'isDiscountable': instance.isDiscountable,
  'mrp': instance.mrp,
  'stockQuantity': instance.stockQuantity,
  'lowStockQuantity': instance.lowStockQuantity,
  'lastStockUpdate': instance.lastStockUpdate?.toIso8601String(),
  'isAvailable': instance.isAvailable,
  'photosList': instance.photosList,
};
