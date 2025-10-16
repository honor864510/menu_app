import 'package:flutter/foundation.dart';
import 'package:menu_app/src/common/pagination_cursor.dart';
import 'package:menu_app/src/feature/menu/model/meal_category_entity.dart';
import 'package:menu_app/src/feature/menu/model/meal_entity.dart';

@immutable
final class MealControllerStateEntity {
  const MealControllerStateEntity({
    required this.meals,
    required this.categories,
    required this.cursor,
    required this.mealsCount,
    required this.selectedMeal,
    required this.selectedCategory,
  });

  factory MealControllerStateEntity.initial() => MealControllerStateEntity(
    categories: const [],
    meals: const [],
    cursor: PaginationCursor.initial(),
    mealsCount: 0,
    selectedCategory: null,
    selectedMeal: null,
  );

  final List<MealEntity> meals;
  final List<MealCategoryEntity> categories;
  final PaginationCursor cursor;
  final int mealsCount;
  final MealEntity? selectedMeal;
  final MealCategoryEntity? selectedCategory;

  MealControllerStateEntity copyWith({
    List<MealEntity>? meals,
    List<MealCategoryEntity>? categories,
    PaginationCursor? cursor,
    int? mealsCount,
    MealEntity? selectedMeal,
    MealCategoryEntity? selectedCategory,
  }) => MealControllerStateEntity(
    meals: meals ?? this.meals,
    categories: categories ?? this.categories,
    cursor: cursor ?? this.cursor,
    mealsCount: mealsCount ?? this.mealsCount,
    selectedMeal: selectedMeal ?? this.selectedMeal,
    selectedCategory: selectedCategory ?? this.selectedCategory,
  );

  // Optional: Add equality and toString for better debugging
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MealControllerStateEntity &&
        listEquals(other.meals, meals) &&
        listEquals(other.categories, categories) &&
        cursor == other.cursor &&
        other.mealsCount == mealsCount &&
        other.selectedMeal == selectedMeal &&
        other.selectedCategory == selectedCategory;
  }

  @override
  int get hashCode =>
      meals.hashCode ^
      categories.hashCode ^
      cursor.hashCode ^
      mealsCount.hashCode ^
      selectedMeal.hashCode ^
      selectedCategory.hashCode;
}

/// {@template meal_controller_state}
/// MealControllerState.
/// {@endtemplate}
sealed class MealControllerState extends _$MealControllerStateBase {
  /// {@macro meal_controller_state}
  const MealControllerState({required super.data, required super.message});

  /// Idle
  /// {@macro meal_controller_state}
  const factory MealControllerState.idle({required MealControllerStateEntity data, String message}) =
      MealControllerState$Idle;

  /// Processing
  /// {@macro meal_controller_state}
  const factory MealControllerState.processing({required MealControllerStateEntity data, String message}) =
      MealControllerState$Processing;

  /// Failed
  /// {@macro meal_controller_state}
  const factory MealControllerState.failed({required MealControllerStateEntity data, String message}) =
      MealControllerState$Failed;

  /// Initial
  /// {@macro meal_controller_state}
  factory MealControllerState.initial({required MealControllerStateEntity data, String? message}) =>
      MealControllerState$Idle(data: data, message: message ?? 'Initial');
}

/// Idle
final class MealControllerState$Idle extends MealControllerState {
  const MealControllerState$Idle({required super.data, super.message = 'Idle'});

  @override
  String get type => 'idle';
}

/// Processing
final class MealControllerState$Processing extends MealControllerState {
  const MealControllerState$Processing({required super.data, super.message = 'Processing'});

  @override
  String get type => 'processing';
}

/// Failed
final class MealControllerState$Failed extends MealControllerState {
  const MealControllerState$Failed({required super.data, super.message = 'Failed'});

  @override
  String get type => 'failed';
}

@immutable
abstract base class _$MealControllerStateBase {
  const _$MealControllerStateBase({required this.data, required this.message});

  /// Type alias for [MealControllerState].
  abstract final String type;

  /// Data entity payload.
  @nonVirtual
  final MealControllerStateEntity data;

  /// Message or description.
  @nonVirtual
  final String message;

  /// Check if is Idle.
  bool get isIdle => this is MealControllerState$Idle;

  /// Check if is Processing.
  bool get isProcessing => this is MealControllerState$Processing;

  /// Check if is Failed.
  bool get isFailed => this is MealControllerState$Failed;
}
