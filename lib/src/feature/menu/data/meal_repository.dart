import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:menu_app/src/feature/menu/model/meal_category_entity.dart';
import 'package:menu_app/src/feature/menu/model/meal_entity.dart';

abstract interface class IMealRepository {
  Future<List<MealCategoryEntity>> fetchCategories();
  Future<(int, List<MealEntity>)> fetchMeals(String? categoryId, {int? limit, int? offset});
}

final class FakeMealRepository implements IMealRepository {
  static final _categories = [
    const MealCategoryEntity(id: 'bbqs', name: 'BBQs', fileName: 'bbqs.json'),
    const MealCategoryEntity(id: 'best-foods', name: 'Best Foods', fileName: 'best-foods.json'),
    const MealCategoryEntity(id: 'breads', name: 'Breads', fileName: 'breads.json'),
    const MealCategoryEntity(id: 'burgers', name: 'Burgers', fileName: 'burgers.json'),
    const MealCategoryEntity(id: 'chocolates', name: 'Chocolates', fileName: 'chocolates.json'),
    const MealCategoryEntity(id: 'desserts', name: 'Desserts', fileName: 'desserts.json'),
    const MealCategoryEntity(id: 'drinks', name: 'Drinks', fileName: 'drinks.json'),
    const MealCategoryEntity(id: 'fried-chicken', name: 'Fried Chicken', fileName: 'fried-chicken.json'),
    const MealCategoryEntity(id: 'ice-cream', name: 'Ice Cream', fileName: 'ice-cream.json'),
    const MealCategoryEntity(id: 'our-foods', name: 'Our Foods', fileName: 'our-foods.json'),
    const MealCategoryEntity(id: 'pizzas', name: 'Pizzas', fileName: 'pizzas.json'),
    const MealCategoryEntity(id: 'porks', name: 'Porks', fileName: 'porks.json'),
    const MealCategoryEntity(id: 'sandwiches', name: 'Sandwiches', fileName: 'sandwiches.json'),
    const MealCategoryEntity(id: 'sausages', name: 'Sausages', fileName: 'sausages.json'),
    const MealCategoryEntity(id: 'steaks', name: 'Steaks', fileName: 'steaks.json'),
  ];

  @override
  Future<List<MealCategoryEntity>> fetchCategories() => Future.value(_categories);

  @override
  Future<(int, List<MealEntity>)> fetchMeals(String? categoryId, {int? limit, int? offset}) async {
    if (categoryId == null) return (0, <MealEntity>[]);

    // Find the category to get the file name
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => throw Exception('Category not found: $categoryId'),
    );

    // Load the JSON file from assets
    final jsonString = await rootBundle.loadString('assets/menus/${category.fileName}');
    final jsonData = json.decode(jsonString) as List;

    // Convert to MealEntity list
    final allMeals = jsonData.map((mealJson) => MealEntity.fromJson(mealJson as Map<String, dynamic>)).toList();

    // Apply pagination
    final totalCount = allMeals.length;
    final startIndex = offset ?? 0;
    final endIndex = limit != null ? startIndex + limit : totalCount;

    // Ensure we don't go out of bounds
    final paginatedMeals = allMeals.sublist(startIndex.clamp(0, totalCount), endIndex.clamp(0, totalCount));

    return (totalCount, paginatedMeals);
  }
}
