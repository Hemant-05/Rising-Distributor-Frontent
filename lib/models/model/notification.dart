import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final String? id;
  final String? title;
  final String? message;
  final String? type;
  @JsonKey(name: 'isRead', readValue: _readStatusValue, defaultValue: false)
  bool read;
  final String? createdAt;

  static Object? _readStatusValue(Map json, String key) =>
      json['isRead'] ?? json['read'];

  NotificationModel({
    this.id,
    this.title,
    this.message,
    this.type,
    this.read = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
