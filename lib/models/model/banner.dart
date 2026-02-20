import 'package:json_annotation/json_annotation.dart';

part 'banner.g.dart';

@JsonSerializable()
class Banner {
  final int? id;
  final String? imageUrl;
  final String? redirectRoute;
  final bool? isActive;

  Banner({
    this.id,
    this.imageUrl,
    this.redirectRoute,
    this.isActive,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => _$BannerFromJson(json);
  Map<String, dynamic> toJson() => _$BannerToJson(this);
}