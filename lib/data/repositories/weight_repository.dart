import '../../domain/models/weight_record.dart';

class WeightRepository {
  final List<WeightRecord> _records = [];

  List<WeightRecord> getAll() => List.unmodifiable(_records);

  List<WeightRecord> getByBaby(String babyId) =>
      _records.where((r) => r.babyId == babyId).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  void add(WeightRecord record) => _records.add(record);

  void update(WeightRecord record) {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) _records[index] = record;
  }

  void delete(String id) => _records.removeWhere((r) => r.id == id);
}
