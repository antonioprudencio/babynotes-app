import 'package:flutter/foundation.dart';
import '../domain/models/meal.dart';
import '../data/repositories/meal_repository.dart';

class MealViewModel extends ChangeNotifier {
  final MealRepository _repository;

  MealViewModel(this._repository) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  List<Meal> get meals => _repository.getAll();

  void add(Meal meal) {
    _repository.add(meal.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }

  void update(Meal meal) {
    _repository.update(meal);
    notifyListeners();
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
