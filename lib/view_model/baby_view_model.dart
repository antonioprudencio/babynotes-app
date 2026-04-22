import 'package:flutter/foundation.dart';
import '../domain/models/baby.dart';
import '../data/repositories/baby_repository.dart';

class BabyViewModel extends ChangeNotifier {
  final BabyRepository _repository;

  BabyViewModel(this._repository) {
    _init();
  }

  Future<void> _init() async {
    await _repository.init();
    notifyListeners();
  }

  List<Baby> get babies => _repository.getAll();

  void add(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _repository.add(Baby(id: id, name: name));
    notifyListeners();
  }

  void update(String id, String name) {
    _repository.update(Baby(id: id, name: name));
    notifyListeners();
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
