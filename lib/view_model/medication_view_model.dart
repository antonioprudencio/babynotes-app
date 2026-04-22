import 'package:flutter/foundation.dart';
import '../domain/models/medication.dart';
import '../data/repositories/medication_repository.dart';

class MedicationViewModel extends ChangeNotifier {
  final MedicationRepository _repository;

  MedicationViewModel(this._repository) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  List<Medication> get medications => _repository.getAll();

  void add(Medication medication) {
    _repository.add(medication.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }

  void update(Medication medication) {
    _repository.update(medication);
    notifyListeners();
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
