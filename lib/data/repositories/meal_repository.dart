import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/sync_status.dart';

class MealRepository {
  static const _key = 'meals';
  final List<Meal> _meals = [];

  List<Meal> getAll() => List.unmodifiable(_meals);

  Meal? getById(String id) {
    try {
      return _meals.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Meal> getPending() =>
      _meals.where((m) => m.syncStatus != SyncStatus.synced).toList();

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

  void upsert(Meal meal) {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal;
    } else {
      _meals.add(meal);
    }
    _save();
  }

  void markSynced(String id) {
    final index = _meals.indexWhere((m) => m.id == id);
    if (index != -1) {
      _meals[index] = _meals[index].copyWith(syncStatus: SyncStatus.synced);
      _save();
    }
  }

  void delete(String id) {
    _meals.removeWhere((m) => m.id == id);
    _save();
  }
}
