import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/weight_record.dart';
import '../domain/models/sync_status.dart';
import '../data/repositories/weight_repository.dart';
import '../data/services/sync_service.dart';

class WeightViewModel extends ChangeNotifier {
  final WeightRepository _repository;
  final SyncService _syncService;
  static const _uuid = Uuid();

  WeightViewModel(this._repository, this._syncService) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  void refresh() => notifyListeners();

  List<WeightRecord> getByBaby(String babyId) =>
      _repository.getByBaby(babyId)
          .where((r) => r.syncStatus != SyncStatus.pendingDelete)
          .toList();

  List<WeightRecord> get allRecords {
    final list = _repository.getAll()
        .where((r) => r.syncStatus != SyncStatus.pendingDelete)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void add(WeightRecord record) {
    _repository.add(record.copyWith(
      id: _uuid.v4(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingCreate,
    ));
    notifyListeners();
    _syncService.syncAll().then((_) => notifyListeners());
  }

  void update(WeightRecord record) {
    _repository.update(record.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: record.syncStatus == SyncStatus.pendingCreate
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
