import 'package:json_annotation/json_annotation.dart';

part 'address_request.g.dart';

@JsonSerializable()
class AddressRequest {
  final String? recipientName;
  final String? phoneNumber;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? title;
  final double? latitude;
  final double? longitude;

  AddressRequest({
    this.recipientName,
    this.phoneNumber,
    this.streetAddress,
    this.city,
    this.state,
    this.zipCode,
    this.title,
    this.latitude,
    this.longitude,
  });

  factory AddressRequest.fromJson(Map<String, dynamic> json) => _$AddressRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}