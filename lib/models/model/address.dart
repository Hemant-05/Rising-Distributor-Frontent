import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final int? id;
  final String? userId;
  final String? title;
  final String? recipientName;
  final String? phoneNumber;
  final String? streetAddress;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final String? zipCode;
  final bool? primary;

  Address({
    this.id,
    this.userId,
    this.title,
    this.recipientName,
    this.phoneNumber,
    this.streetAddress,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.zipCode,
    this.primary,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}