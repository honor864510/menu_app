import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:menu_app/src/feature/menu/controller/meal_controller.dart';
import 'package:menu_app/src/feature/menu/controller/meal_controller_state.dart';
import 'package:menu_app/src/feature/menu/data/meal_repository.dart';
import 'package:menu_app/src/feature/menu/model/meal_category_entity.dart';
import 'package:menu_app/src/feature/menu/model/meal_entity.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  late final MealController _controller;
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _controller = MealController(repository: FakeMealRepository());
    _controller
      ..fetchCategories()
      ..fetchMeals();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_scrollListener)
      ..dispose();
    _searchController.dispose();

    if (!_controller.isDisposed) _controller.dispose();

    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 100) {
      _controller.fetchMoreMeals();
    }
  }

  void _onSearchChanged(String query) {
    query.isEmpty ? _controller.fetchMeals() : _controller.searchMeals(query);
  }

  void _onCategorySelected(MealCategoryEntity category) => _controller.selectCategory(category);

  void _onMealSelected(MealEntity meal) {
    _controller.selectMeal(meal);
    _showMealDetails(meal);
  }

  void _showMealDetails(MealEntity meal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MealDetailsBottomSheet(meal: meal),
    );
  }

  void _onRefresh() => _controller.refreshAll();

  void _clearSelectedCategory() => _controller.clearSelectedCategory();

  @override
  Widget build(BuildContext context) => ControllerScope(
    () => _controller,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _onRefresh, tooltip: 'Refresh')],
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController, onChanged: _onSearchChanged),
          _CategoriesSection(controller: _controller, onClear: _clearSelectedCategory, onSelect: _onCategorySelected),
          Expanded(
            child: _MealsSection(
              controller: _controller,
              scrollController: _scrollController,
              onMealSelected: _onMealSelected,
              onRefresh: _onRefresh,
            ),
          ),
        ],
      ),
    ),
  );
}

// ========================== PRIVATE WIDGETS ===========================

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search meals...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onChanged: onChanged,
    ),
  );
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.controller, required this.onClear, required this.onSelect});

  final MealController controller;
  final VoidCallback onClear;
  final ValueChanged<MealCategoryEntity> onSelect;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 80,
    child: StateConsumer<MealController, MealControllerState>(
      buildWhen: (previous, current) =>
          previous.data.selectedCategory != current.data.selectedCategory ||
          previous.data.categories != current.data.categories,
      builder: (context, state, _) {
        final categories = state.data.categories;
        final selected = state.data.selectedCategory;

        if (categories.isEmpty && state.isProcessing) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: categories.length + (selected != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (selected != null && index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: ActionChip(
                  label: const Text('Clear Filter'),
                  onPressed: onClear,
                  backgroundColor: Colors.grey[300],
                  avatar: const Icon(Icons.clear, size: 16),
                ),
              );
            }

            final catIndex = selected != null ? index - 1 : index;
            final category = categories[catIndex];
            final isSelected = selected?.id == category.id;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) => onSelect(category),
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                labelStyle: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class _MealsSection extends StatelessWidget {
  const _MealsSection({
    required this.controller,
    required this.scrollController,
    required this.onMealSelected,
    required this.onRefresh,
  });

  final MealController controller;
  final ScrollController scrollController;
  final ValueChanged<MealEntity> onMealSelected;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => StateConsumer<MealController, MealControllerState>(
    buildWhen: (previous, current) =>
        previous.data.meals != current.data.meals ||
        previous.data.cursor != current.data.cursor ||
        previous.data.selectedCategory != current.data.selectedCategory,
    builder: (context, state, _) {
      final meals = state.data.meals;
      final hasMore = state.data.cursor.hasMore;
      final selectedCategory = state.data.selectedCategory;

      if (state.isProcessing && meals.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state.isFailed) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load meals', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(state.message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRefresh, child: const Text('Retry')),
            ],
          ),
        );
      }

      if (meals.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fastfood, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                selectedCategory == null
                    ? 'Select a category to see meals'
                    : 'No meals found in ${selectedCategory.name}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (selectedCategory != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRefresh, child: const Text('Clear Filter')),
              ],
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView.builder(
          controller: scrollController,
          itemCount: meals.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == meals.length && hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final meal = meals[index];
            return _MealItem(meal: meal, onTap: () => onMealSelected(meal));
          },
        ),
      );
    },
  );
}

class _MealItem extends StatelessWidget {
  const _MealItem({required this.meal, required this.onTap});

  final MealEntity meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(backgroundImage: NetworkImage(meal.img), radius: 30, backgroundColor: Colors.grey[200]),
      title: Text(meal.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(meal.dsc, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text('${meal.rate}'),
              const SizedBox(width: 16),
              const Icon(Icons.attach_money, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text('\$${meal.price.toStringAsFixed(2)}'),
              const Spacer(),
              const Icon(Icons.flag, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text(meal.country),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _MealDetailsBottomSheet extends StatelessWidget {
  const _MealDetailsBottomSheet({required this.meal});
  final MealEntity meal;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    maxChildSize: 0.9,
    minChildSize: 0.5,
    builder: (context, scrollController) => SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: NetworkImage(meal.img), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Text(meal.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${meal.rate}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                Text(
                  '\$${meal.price.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Spacer(),
                const Icon(Icons.flag, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(meal.country, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text(meal.dsc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${meal.name} to cart')));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
