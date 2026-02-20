import 'package:json_annotation/json_annotation.dart';

part 'user_profile_response.g.dart';

@JsonSerializable()
class UserProfileResponse {
  final String? uid;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final bool? isMobileVerified;
  final String? role;

  UserProfileResponse({
    this.uid,
    this.name,
    this.email,
    this.mobileNumber,
    this.isMobileVerified,
    this.role,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) => _$UserProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);
}