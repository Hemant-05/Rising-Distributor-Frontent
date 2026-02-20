import 'package:json_annotation/json_annotation.dart';

part 'cart_dtos.g.dart';

@JsonSerializable()
class CartItemDto {
  final String? productId;
  final int? quantity;

  CartItemDto({this.productId, this.quantity});

  factory CartItemDto.fromJson(Map<String, dynamic> json) => _$CartItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemDtoToJson(this);
}

@JsonSerializable()
class CartRequestDto {
  final String? productId;
  final int? quantity;

  CartRequestDto({this.productId, this.quantity});

  factory CartRequestDto.fromJson(Map<String, dynamic> json) => _$CartRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CartRequestDtoToJson(this);
}