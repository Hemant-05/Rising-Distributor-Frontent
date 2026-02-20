// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wishlist _$WishlistFromJson(Map<String, dynamic> json) => Wishlist(
  id: (json['id'] as num?)?.toInt(),
  userId: json['userId'] as String?,
  product: json['product'] == null
      ? null
      : Product.fromJson(json['product'] as Map<String, dynamic>),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WishlistToJson(Wishlist instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'product': instance.product?.toJson(),
  'createdAt': instance.createdAt?.toIso8601String(),
};
