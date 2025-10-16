import 'package:control/control.dart';
import 'package:menu_app/src/common/pagination_cursor.dart';
import 'package:menu_app/src/feature/menu/controller/meal_controller_state.dart';
import 'package:menu_app/src/feature/menu/data/meal_repository.dart';
import 'package:menu_app/src/feature/menu/model/meal_category_entity.dart';
import 'package:menu_app/src/feature/menu/model/meal_entity.dart';

final class MealController extends StateController<MealControllerState> with SequentialControllerHandler {
  MealController({required IMealRepository repository})
    : _repository = repository,
      super(initialState: MealControllerState.initial(data: MealControllerStateEntity.initial()));

  final IMealRepository _repository;

  void fetchCategories() => handle(
    () async {
      setState(MealControllerState.processing(data: state.data, message: 'Fetching categories'));

      final categories = await _repository.fetchCategories();

      setState(
        MealControllerState.processing(
          data: state.data.copyWith(categories: categories),
          message: 'Categories fetched',
        ),
      );
    },
    error: (error, stackTrace) async =>
        setState(MealControllerState.failed(data: state.data, message: 'Failed to fetch categories')),
    done: () async => setState(MealControllerState.idle(data: state.data, message: 'Idle')),
  );

  void fetchMeals() => handle(
    () async {
      setState(MealControllerState.processing(data: state.data, message: 'Fetching meals'));

      final newCursor = PaginationCursor.initial();
      final (mealsCount, meals) = await _repository.fetchMeals(
        state.data.selectedCategory?.id,
        limit: newCursor.limit,
        offset: newCursor.offset,
      );

      final hasMore = meals.length < newCursor.limit;
      final updatedCursor = newCursor.copyWith(hasMore: hasMore, offset: hasMore ? newCursor.limit : meals.length);

      setState(
        MealControllerState.processing(
          data: state.data.copyWith(mealsCount: mealsCount, meals: meals, cursor: updatedCursor),
          message: 'Meals fetched',
        ),
      );
    },
    error: (error, stackTrace) async =>
        setState(MealControllerState.failed(data: state.data, message: 'Failed to fetch meals')),
    done: () async => setState(MealControllerState.idle(data: state.data, message: 'Idle')),
  );

  void fetchMoreMeals() => handle(
    () async {
      if (!state.data.cursor.hasMore) return;

      setState(MealControllerState.processing(data: state.data, message: 'Fetching meals'));

      final (mealsCount, meals) = await _repository.fetchMeals(
        state.data.selectedCategory?.id,
        limit: state.data.cursor.limit,
        offset: state.data.cursor.offset,
      );

      final hasMore = meals.length < state.data.cursor.limit;
      final updatedCursor = state.data.cursor.copyWith(
        hasMore: hasMore,
        offset: state.data.cursor.offset + (hasMore ? state.data.cursor.limit : meals.length),
      );

      // Merge new meals with existing ones, avoiding duplicates by id
      final existingMealIds = state.data.meals.map((e) => e.id).toSet();
      final uniqueNewMeals = meals.where((meal) => !existingMealIds.contains(meal.id)).toList();
      final allMeals = [...state.data.meals, ...uniqueNewMeals];

      setState(
        MealControllerState.processing(
          data: state.data.copyWith(mealsCount: mealsCount, meals: allMeals, cursor: updatedCursor),
          message: 'Meals fetched',
        ),
      );
    },
    error: (error, stackTrace) async =>
        setState(MealControllerState.failed(data: state.data, message: 'Failed to fetch meals')),
    done: () async => setState(MealControllerState.idle(data: state.data, message: 'Idle')),
  );

  /// Select a category and optionally fetch meals for that category
  void selectCategory(MealCategoryEntity? category) => handle(
    () async {
      setState(
        MealControllerState.processing(
          data: state.data.copyWith(selectedCategory: category),
          message: 'Selecting category',
        ),
      );

      // Reset pagination when selecting a new category
      final newCursor = PaginationCursor.initial();
      final (mealsCount, meals) = await _repository.fetchMeals(
        category?.id,
        limit: newCursor.limit,
        offset: newCursor.offset,
      );

      final hasMore = meals.length < newCursor.limit;
      final updatedCursor = newCursor.copyWith(hasMore: hasMore, offset: hasMore ? newCursor.limit : meals.length);

      setState(
        MealControllerState.processing(
          data: state.data.copyWith(
            selectedCategory: category,
            mealsCount: mealsCount,
            meals: meals,
            cursor: updatedCursor,
          ),
          message: 'Category selected and meals fetched',
        ),
      );
    },
    error: (error, stackTrace) async =>
        setState(MealControllerState.failed(data: state.data, message: 'Failed to select category')),
    done: () async => setState(MealControllerState.idle(data: state.data, message: 'Idle')),
  );

  /// Select a meal for detailed view
  void selectMeal(MealEntity? meal) {
    setState(
      MealControllerState.idle(
        data: state.data.copyWith(selectedMeal: meal),
        message: 'Meal selected',
      ),
    );
  }

  /// Clear selected meal
  void clearSelectedMeal() {
    setState(
      MealControllerState.idle(data: state.data.copyWith(selectedMeal: null), message: 'Meal selection cleared'),
    );
  }

  /// Clear selected category and reset meals
  void clearSelectedCategory() {
    setState(
      MealControllerState.idle(
        data: state.data.copyWith(
          selectedCategory: null,
          meals: const [],
          mealsCount: 0,
          cursor: PaginationCursor.initial(),
        ),
        message: 'Category cleared',
      ),
    );
  }

  /// Refresh all data (categories and meals)
  void refreshAll() => handle(
    () async {
      setState(MealControllerState.processing(data: state.data, message: 'Refreshing all data'));

      // Fetch categories and meals in parallel
      final (categories, (mealsCount, meals)) = await (
        _repository.fetchCategories(),
        _repository.fetchMeals(
          state.data.selectedCategory?.id,
          limit: state.data.cursor.limit,
          offset: 0, // Reset to beginning
        ),
      ).wait;

      final newCursor = PaginationCursor.initial();
      final hasMore = meals.length < newCursor.limit;
      final updatedCursor = newCursor.copyWith(hasMore: hasMore, offset: hasMore ? newCursor.limit : meals.length);

      setState(
        MealControllerState.processing(
          data: state.data.copyWith(
            categories: categories,
            mealsCount: mealsCount,
            meals: meals,
            cursor: updatedCursor,
          ),
          message: 'All data refreshed',
        ),
      );
    },
    error: (error, stackTrace) async =>
        setState(MealControllerState.failed(data: state.data, message: 'Failed to refresh data')),
    done: () async => setState(MealControllerState.idle(data: state.data, message: 'Idle')),
  );

  /// Search meals by query
  void searchMeals(String query) => handle(
    () async {
      setState(MealControllerState.processing(data: state.data, message: 'Searching meals'));

      final (mealsCount, meals) = await _repository.searchMeals(query, categoryId: state.data.selectedCategory?.id);

      setState(
        MealControllerState.processing(
          data: state.data.copyWith(
            mealsCount: mealsCount,
            meals: meals,
            cursor: PaginationCursor.initial().copyWith(hasMore: false), // No pagination for search
          ),
          message: query.isEmpty ? 'Search cleared' : 'Search completed',
        ),
      );
    },
    error: (error, stackTrace) async =>
        setState(MealControllerState.failed(data: state.data, message: 'Failed to search meals')),
    done: () async => setState(MealControllerState.idle(data: state.data, message: 'Idle')),
  );
}
