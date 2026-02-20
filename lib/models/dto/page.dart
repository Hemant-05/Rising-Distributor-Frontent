// lib/models/dto/page.dart
import 'package:json_annotation/json_annotation.dart';

part 'page.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Page<T> {
  final List<T>? content;
  final int? totalPages;
  final int? totalElements;
  final bool? last;
  final int? size;
  final int? number;

  Page({
    this.content,
    this.totalPages,
    this.totalElements,
    this.last,
    this.size,
    this.number,
  });

  factory Page.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PageFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageToJson(this, toJsonT);
}