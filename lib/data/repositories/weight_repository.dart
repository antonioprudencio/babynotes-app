import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/weight_record.dart';

class WeightRepository {
  static const _key = 'weight_records';
  final List<WeightRecord> _records = [];

  List<WeightRecord> getAll() => List.unmodifiable(_records);

  List<WeightRecord> getByBaby(String babyId) =>
      _records.where((r) => r.babyId == babyId).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    _records.clear();
    _records.addAll(jsonList.map((s) => WeightRecord.fromJson(jsonDecode(s) as Map<String, dynamic>)));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _records.map((r) => jsonEncode(r.toJson())).toList());
  }

  void add(WeightRecord record) {
    _records.add(record);
    _save();
  }

  void update(WeightRecord record) {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _records[index] = record;
      _save();
    }
  }

  void delete(String id) {
    _records.removeWhere((r) => r.id == id);
    _save();
  }
}
