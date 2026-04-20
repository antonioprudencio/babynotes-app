import 'package:flutter/foundation.dart';
import '../domain/models/weight_record.dart';
import '../data/repositories/weight_repository.dart';

class WeightViewModel extends ChangeNotifier {
  final WeightRepository _repository;

  WeightViewModel(this._repository);

  List<WeightRecord> getByBaby(String babyId) => _repository.getByBaby(babyId);

  List<WeightRecord> get allRecords {
    final list = List<WeightRecord>.from(_repository.getAll());
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void add(WeightRecord record) {
    _repository.add(record.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }

  void update(WeightRecord record) {
    _repository.update(record);
    notifyListeners();
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
