import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/models/sync_status.dart';
import '../repositories/baby_repository.dart';
import '../repositories/hygiene_repository.dart';
import '../repositories/meal_repository.dart';
import '../repositories/medication_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/weight_repository.dart';
import 'baby_api_service.dart';
import 'hygiene_api_service.dart';
import 'meal_api_service.dart';
import 'medication_api_service.dart';
import 'weight_record_api_service.dart';

class SyncService {
  final UserRepository _userRepo;
  final BabyRepository _babyRepo;
  final MealRepository _mealRepo;
  final HygieneRepository _hygieneRepo;
  final MedicationRepository _medicationRepo;
  final WeightRepository _weightRepo;
  final BabyApiService _babyApi;
  final MealApiService _mealApi;
  final HygieneApiService _hygieneApi;
  final MedicationApiService _medicationApi;
  final WeightRecordApiService _weightApi;

  SyncService({
    required UserRepository userRepo,
    required BabyRepository babyRepo,
    required MealRepository mealRepo,
    required HygieneRepository hygieneRepo,
    required MedicationRepository medicationRepo,
    required WeightRepository weightRepo,
    required BabyApiService babyApi,
    required MealApiService mealApi,
    required HygieneApiService hygieneApi,
    required MedicationApiService medicationApi,
    required WeightRecordApiService weightApi,
  })  : _userRepo = userRepo,
        _babyRepo = babyRepo,
        _mealRepo = mealRepo,
        _hygieneRepo = hygieneRepo,
        _medicationRepo = medicationRepo,
        _weightRepo = weightRepo,
        _babyApi = babyApi,
        _mealApi = mealApi,
        _hygieneApi = hygieneApi,
        _medicationApi = medicationApi,
        _weightApi = weightApi;

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  Future<void> syncAll() async {
    if (!await _isOnline()) return;
    final userId = _userRepo.currentUser?.id;
    if (userId == null) return;

    await _push(userId);
    await _pull(userId);
    await _userRepo.setLastSyncTime(DateTime.now());
  }

  // ---------- PUSH: local → API ----------

  Future<void> _push(String userId) async {
    await _pushBabies(userId);
    await _pushMeals();
    await _pushHygiene();
    await _pushMedications();
    await _pushWeightRecords();
  }

  Future<void> _pushBabies(String userId) async {
    for (final baby in _babyRepo.getPending()) {
      try {
        switch (baby.syncStatus) {
          case SyncStatus.pendingCreate:
            final created = await _babyApi.create(baby, userId);
            _babyRepo.upsert(created);
            break;
          case SyncStatus.pendingUpdate:
            final updated = await _babyApi.update(baby);
            _babyRepo.upsert(updated);
            break;
          case SyncStatus.pendingDelete:
            await _babyApi.delete(baby.id);
            _babyRepo.delete(baby.id);
            break;
          case SyncStatus.synced:
            break;
        }
      } catch (_) {
        // mantém pendente para tentar na próxima vez
      }
    }
  }

  Future<void> _pushMeals() async {
    for (final meal in _mealRepo.getPending()) {
      try {
        switch (meal.syncStatus) {
          case SyncStatus.pendingCreate:
            final created = await _mealApi.create(meal);
            _mealRepo.upsert(created);
            break;
          case SyncStatus.pendingUpdate:
            final updated = await _mealApi.update(meal);
            _mealRepo.upsert(updated);
            break;
          case SyncStatus.pendingDelete:
            await _mealApi.delete(meal.id);
            _mealRepo.delete(meal.id);
            break;
          case SyncStatus.synced:
            break;
        }
      } catch (_) {}
    }
  }

  Future<void> _pushHygiene() async {
    for (final item in _hygieneRepo.getPending()) {
      try {
        switch (item.syncStatus) {
          case SyncStatus.pendingCreate:
            final created = await _hygieneApi.create(item);
            _hygieneRepo.upsert(created);
            break;
          case SyncStatus.pendingUpdate:
            final updated = await _hygieneApi.update(item);
            _hygieneRepo.upsert(updated);
            break;
          case SyncStatus.pendingDelete:
            await _hygieneApi.delete(item.id);
            _hygieneRepo.delete(item.id);
            break;
          case SyncStatus.synced:
            break;
        }
      } catch (_) {}
    }
  }

  Future<void> _pushMedications() async {
    for (final med in _medicationRepo.getPending()) {
      try {
        switch (med.syncStatus) {
          case SyncStatus.pendingCreate:
            final created = await _medicationApi.create(med);
            _medicationRepo.upsert(created);
            break;
          case SyncStatus.pendingUpdate:
            final updated = await _medicationApi.update(med);
            _medicationRepo.upsert(updated);
            break;
          case SyncStatus.pendingDelete:
            await _medicationApi.delete(med.id);
            _medicationRepo.delete(med.id);
            break;
          case SyncStatus.synced:
            break;
        }
      } catch (_) {}
    }
  }

  Future<void> _pushWeightRecords() async {
    for (final record in _weightRepo.getPending()) {
      try {
        switch (record.syncStatus) {
          case SyncStatus.pendingCreate:
            final created = await _weightApi.create(record);
            _weightRepo.upsert(created);
            break;
          case SyncStatus.pendingUpdate:
            final updated = await _weightApi.update(record);
            _weightRepo.upsert(updated);
            break;
          case SyncStatus.pendingDelete:
            await _weightApi.delete(record.id);
            _weightRepo.delete(record.id);
            break;
          case SyncStatus.synced:
            break;
        }
      } catch (_) {}
    }
  }

  // ---------- PULL: API → local ----------

  Future<void> _pull(String userId) async {
    final lastSync = await _userRepo.getLastSyncTime();

    // 1. Puxa bebês (com acesso do usuário)
    final serverBabies = await _babyApi.fetchAll(userId, updatedSince: lastSync);
    for (final serverBaby in serverBabies) {
      final local = _babyRepo.getById(serverBaby.id);
      if (local == null || local.syncStatus == SyncStatus.synced) {
        _babyRepo.upsert(serverBaby);
      }
      // se local tem pendente → local vence, ignora
    }

    // 2. Para cada bebê local, puxa registros relacionados
    final babyIds = _babyRepo.getAll().map((b) => b.id).toSet();
    for (final babyId in babyIds) {
      await _pullMeals(babyId, lastSync);
      await _pullHygiene(babyId, lastSync);
      await _pullMedications(babyId, lastSync);
      await _pullWeightRecords(babyId, lastSync);
    }
  }

  Future<void> _pullMeals(String babyId, DateTime? since) async {
    try {
      final serverItems = await _mealApi.fetchByBaby(babyId, updatedSince: since);
      for (final item in serverItems) {
        final local = _mealRepo.getById(item.id);
        if (local == null || local.syncStatus == SyncStatus.synced) {
          _mealRepo.upsert(item);
        }
      }
    } catch (_) {}
  }

  Future<void> _pullHygiene(String babyId, DateTime? since) async {
    try {
      final serverItems = await _hygieneApi.fetchByBaby(babyId, updatedSince: since);
      for (final item in serverItems) {
        final local = _hygieneRepo.getById(item.id);
        if (local == null || local.syncStatus == SyncStatus.synced) {
          _hygieneRepo.upsert(item);
        }
      }
    } catch (_) {}
  }

  Future<void> _pullMedications(String babyId, DateTime? since) async {
    try {
      final serverItems = await _medicationApi.fetchByBaby(babyId, updatedSince: since);
      for (final item in serverItems) {
        final local = _medicationRepo.getById(item.id);
        if (local == null || local.syncStatus == SyncStatus.synced) {
          _medicationRepo.upsert(item);
        }
      }
    } catch (_) {}
  }

  Future<void> _pullWeightRecords(String babyId, DateTime? since) async {
    try {
      final serverItems = await _weightApi.fetchByBaby(babyId, updatedSince: since);
      for (final item in serverItems) {
        final local = _weightRepo.getById(item.id);
        if (local == null || local.syncStatus == SyncStatus.synced) {
          _weightRepo.upsert(item);
        }
      }
    } catch (_) {}
  }
}
