import 'package:flutter/foundation.dart';
import '../domain/models/hygiene.dart';
import '../data/repositories/hygiene_repository.dart';

class HygieneViewModel extends ChangeNotifier {
  final HygieneRepository _repository;

  HygieneViewModel(this._repository) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  List<Hygiene> get hygienes => _repository.getAll();

  void add(Hygiene hygiene) {
    _repository.add(hygiene.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }

  void update(Hygiene hygiene) {
    _repository.update(hygiene);
    notifyListeners();
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
