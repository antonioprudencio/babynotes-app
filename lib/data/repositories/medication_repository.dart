import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/medication.dart';

class MedicationRepository {
  static const _key = 'medications';
  final List<Medication> _medications = [];

  List<Medication> getAll() => List.unmodifiable(_medications);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    _medications.clear();
    _medications.addAll(jsonList.map((s) => Medication.fromJson(jsonDecode(s) as Map<String, dynamic>)));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _medications.map((m) => jsonEncode(m.toJson())).toList());
  }

  void add(Medication medication) {
    _medications.add(medication);
    _save();
  }

  void update(Medication medication) {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      _save();
    }
  }

  void delete(String id) {
    _medications.removeWhere((m) => m.id == id);
    _save();
  }
}
