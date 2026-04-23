import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/baby.dart';
import '../domain/models/sync_status.dart';
import '../data/repositories/baby_repository.dart';
import '../data/services/sync_service.dart';

class BabyViewModel extends ChangeNotifier {
  final BabyRepository _repository;
  final SyncService _syncService;
  static const _uuid = Uuid();

  BabyViewModel(this._repository, this._syncService) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
    _syncService.syncAll().then((_) => notifyListeners());
  }

  void refresh() => notifyListeners();

  List<Baby> get babies => _repository.getAll()
      .where((b) => b.syncStatus != SyncStatus.pendingDelete)
      .toList();

  void add(String name) {
    _repository.add(Baby(
      id: _uuid.v4(),
      name: name,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingCreate,
    ));
    notifyListeners();
    _syncService.syncAll().then((_) => notifyListeners());
  }

  void update(String id, String name) {
    final existing = _repository.getById(id);
    if (existing == null) return;
    _repository.update(existing.copyWith(
      name: name,
      updatedAt: DateTime.now(),
      syncStatus: existing.syncStatus == SyncStatus.pendingCreate
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
