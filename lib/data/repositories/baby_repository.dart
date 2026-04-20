import '../../domain/models/baby.dart';

class BabyRepository {
  final List<Baby> _babies = [];

  List<Baby> getAll() => List.unmodifiable(_babies);

  void add(Baby baby) => _babies.add(baby);

  void update(Baby baby) {
    final index = _babies.indexWhere((b) => b.id == baby.id);
    if (index != -1) _babies[index] = baby;
  }

  void delete(String id) => _babies.removeWhere((b) => b.id == id);
}
