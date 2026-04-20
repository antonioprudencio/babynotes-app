import '../../domain/models/medication.dart';

class MedicationRepository {
  final List<Medication> _medications = [];

  List<Medication> getAll() => List.unmodifiable(_medications);

  void add(Medication medication) => _medications.add(medication);

  void update(Medication medication) {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) _medications[index] = medication;
  }

  void delete(String id) => _medications.removeWhere((m) => m.id == id);
}
