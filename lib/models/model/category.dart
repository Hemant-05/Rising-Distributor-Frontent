import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable(explicitToJson: true)
class Category {
  final int? id;
  final String? name;
  final String? imageUrl;

  // Self-referencing: A category can have a parent
  final Category? parentCategory;

  // Self-referencing: A category can have children
  final List<Category>? subCategories;

  Category({
    this.id,
    this.name,
    this.imageUrl,
    this.parentCategory,
    this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}