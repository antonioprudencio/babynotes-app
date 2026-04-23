import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/medication.dart';
import '../domain/models/sync_status.dart';
import '../data/repositories/medication_repository.dart';
import '../data/services/sync_service.dart';

class MedicationViewModel extends ChangeNotifier {
  final MedicationRepository _repository;
  final SyncService _syncService;
  static const _uuid = Uuid();

  MedicationViewModel(this._repository, this._syncService) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  void refresh() => notifyListeners();

  List<Medication> get medications => _repository.getAll()
      .where((m) => m.syncStatus != SyncStatus.pendingDelete)
      .toList();

  void add(Medication medication) {
    _repository.add(medication.copyWith(
      id: _uuid.v4(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingCreate,
    ));
    notifyListeners();
    _syncService.syncAll().then((_) => notifyListeners());
  }

  void update(Medication medication) {
    _repository.update(medication.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: medication.syncStatus == SyncStatus.pendingCreate
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
