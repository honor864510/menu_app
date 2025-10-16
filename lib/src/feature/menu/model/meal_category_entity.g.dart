// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealCategoryEntity _$MealCategoryEntityFromJson(Map<String, dynamic> json) =>
    MealCategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      fileName: json['fileName'] as String,
    );

Map<String, dynamic> _$MealCategoryEntityToJson(MealCategoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fileName': instance.fileName,
    };
