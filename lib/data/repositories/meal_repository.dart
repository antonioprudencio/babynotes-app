import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/meal.dart';

class MealRepository {
  static const _key = 'meals';
  final List<Meal> _meals = [];

  List<Meal> getAll() => List.unmodifiable(_meals);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    _meals.clear();
    _meals.addAll(jsonList.map((s) => Meal.fromJson(jsonDecode(s) as Map<String, dynamic>)));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _meals.map((m) => jsonEncode(m.toJson())).toList());
  }

  void add(Meal meal) {
    _meals.add(meal);
    _save();
  }

  void update(Meal meal) {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal;
      _save();
    }
  }

  void delete(String id) {
    _meals.removeWhere((m) => m.id == id);
    _save();
  }
}
