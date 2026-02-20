import 'package:json_annotation/json_annotation.dart';

part 'token_password_dtos.g.dart';

// 1. Refresh Token Request
@JsonSerializable()
class RefreshTokenRequest {
  // Java has @JsonProperty("refresh_token")
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  RefreshTokenRequest({this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

// 2. Reset Password DTO
@JsonSerializable()
class ResetPasswordDto {
  final String? email;
  final String? otp;
  final String? newPassword;

  ResetPasswordDto({this.email, this.otp, this.newPassword});

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) => _$ResetPasswordDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);
}