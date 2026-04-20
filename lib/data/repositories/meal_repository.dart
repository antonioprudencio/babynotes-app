import '../../domain/models/meal.dart';

class MealRepository {
  final List<Meal> _meals = [];

  List<Meal> getAll() => List.unmodifiable(_meals);

  void add(Meal meal) => _meals.add(meal);

  void update(Meal meal) {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) _meals[index] = meal;
  }

  void delete(String id) => _meals.removeWhere((m) => m.id == id);
}
