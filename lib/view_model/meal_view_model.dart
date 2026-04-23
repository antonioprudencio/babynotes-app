import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/meal.dart';
import '../domain/models/sync_status.dart';
import '../data/repositories/meal_repository.dart';
import '../data/services/sync_service.dart';

class MealViewModel extends ChangeNotifier {
  final MealRepository _repository;
  final SyncService _syncService;
  static const _uuid = Uuid();

  MealViewModel(this._repository, this._syncService) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  void refresh() => notifyListeners();

  List<Meal> get meals => _repository.getAll()
      .where((m) => m.syncStatus != SyncStatus.pendingDelete)
      .toList();

  void add(Meal meal) {
    _repository.add(meal.copyWith(
      id: _uuid.v4(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingCreate,
    ));
    notifyListeners();
    _syncService.syncAll().then((_) => notifyListeners());
  }

  void update(Meal meal) {
    _repository.update(meal.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: meal.syncStatus == SyncStatus.pendingCreate
          ? SyncStatus.pendingCreate
          : SyncStatus.pendingUpdate,
    ));
    notifyListeners();
    _syncService.syncAll().then((_) => notifyListeners());
  }

  void delete(String id) {
    final existing = _repository.getById(id);
    if (existing == null) return;
    if (existing.syncStatus == SyncStatus.pendingCreate) {
      _repository.delete(id);
    } else {
      _repository.update(existing.copyWith(syncStatus: SyncStatus.pendingDelete));
      _syncService.syncAll().then((_) => notifyListeners());
    }
    notifyListeners();
  }
}
