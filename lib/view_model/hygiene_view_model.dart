import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/hygiene.dart';
import '../domain/models/sync_status.dart';
import '../data/repositories/hygiene_repository.dart';
import '../data/services/sync_service.dart';

class HygieneViewModel extends ChangeNotifier {
  final HygieneRepository _repository;
  final SyncService _syncService;
  static const _uuid = Uuid();

  HygieneViewModel(this._repository, this._syncService) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  void refresh() => notifyListeners();

  List<Hygiene> get hygienes => _repository.getAll()
      .where((h) => h.syncStatus != SyncStatus.pendingDelete)
      .toList();

  void add(Hygiene hygiene) {
    _repository.add(hygiene.copyWith(
      id: _uuid.v4(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingCreate,
    ));
    notifyListeners();
    _syncService.syncAll().then((_) => notifyListeners());
  }

  void update(Hygiene hygiene) {
    _repository.update(hygiene.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: hygiene.syncStatus == SyncStatus.pendingCreate
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
