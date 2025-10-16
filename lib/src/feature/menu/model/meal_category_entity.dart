import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'meal_category_entity.g.dart';

@immutable
@JsonSerializable()
class MealCategoryEntity {
  const MealCategoryEntity({required this.id, required this.name, required this.fileName});

  factory MealCategoryEntity.fromJson(Map<String, dynamic> json) => _$MealCategoryEntityFromJson(json);

  final String id;
  final String name;
  final String fileName;

  Map<String, dynamic> toJson() => _$MealCategoryEntityToJson(this);
}
