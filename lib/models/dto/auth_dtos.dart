import 'package:json_annotation/json_annotation.dart';

part 'auth_dtos.g.dart';

// 1. Login Request
@JsonSerializable()
class LogInRequest {
  final String? email;
  final String? password;

  LogInRequest({this.email, this.password});

  factory LogInRequest.fromJson(Map<String, dynamic> json) =>
      _$LogInRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LogInRequestToJson(this);
}

// 2. Registration Request
@JsonSerializable()
class RegistrationRequest {
  final String? name;
  final String? email;
  final String? number;
  final String? password;

  RegistrationRequest({this.name, this.email, this.number, this.password});

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}

// 3. Google Customer Auth Request
@JsonSerializable()
class GoogleAuthRequest {
  final String? idToken;
  final String? fcmToken;

  GoogleAuthRequest({this.idToken, this.fcmToken});

  factory GoogleAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GoogleAuthRequestToJson(this);
}
