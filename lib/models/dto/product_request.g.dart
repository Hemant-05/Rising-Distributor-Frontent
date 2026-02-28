// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductRequest _$ProductRequestFromJson(Map<String, dynamic> json) =>
    ProductRequest(
      name: json['name'] as String?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      brandId: (json['brandId'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      measurement: json['measurement'] as String?,
      mrp: (json['mrp'] as num?)?.toDouble(),
      stockQuantity: (json['stockQuantity'] as num?)?.toInt(),
      lowStockQuantity: (json['lowStockQuantity'] as num?)?.toInt(),
      available: json['available'] as bool?,
      discountable: json['discountable'] as bool?,
      photosList: (json['photosList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProductRequestToJson(ProductRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'categoryId': instance.categoryId,
      'brandId': instance.brandId,
      'price': instance.price,
      'description': instance.description,
      'quantity': instance.quantity,
      'measurement': instance.measurement,
      'mrp': instance.mrp,
      'stockQuantity': instance.stockQuantity,
      'lowStockQuantity': instance.lowStockQuantity,
      'available': instance.available,
      'discountable': instance.discountable,
      'photosList': instance.photosList,
      'rating': instance.rating,
    };
