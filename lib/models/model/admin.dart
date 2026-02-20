import 'package:json_annotation/json_annotation.dart';

part 'admin.g.dart';

@JsonSerializable()
class Admin {
  final String? uid;
  final String? name;
  final String? email;
  final String? role;

  // Password is usually excluded in JSON responses for security,
  // but included here to match your Java model exactly.
  final String? password;

  Admin({
    this.uid,
    this.name,
    this.email,
    this.role,
    this.password,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  Map<String, dynamic> toJson() => _$AdminToJson(this);
}