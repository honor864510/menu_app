import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

@immutable
class MealCategoryEntity {
  const MealCategoryEntity({required this.id, required this.name, required this.fileName});

  factory MealCategoryEntity.fromJson(Map<String, dynamic> json) => MealCategoryEntity(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    fileName: json['fileName'] as String? ?? '',
  );

  final String id;
  final String name;
  final String fileName;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'fileName': fileName};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MealCategoryEntity && other.id == id && other.name == name && other.fileName == fileName;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ fileName.hashCode;

  @override
  String toString() => 'MealCategoryEntity(id: $id, name: $name, fileName: $fileName)';
}
