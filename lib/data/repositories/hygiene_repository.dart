import '../../domain/models/hygiene.dart';

class HygieneRepository {
  final List<Hygiene> _items = [];

  List<Hygiene> getAll() => List.unmodifiable(_items);

  void add(Hygiene hygiene) => _items.add(hygiene);

  void update(Hygiene hygiene) {
    final index = _items.indexWhere((h) => h.id == hygiene.id);
    if (index != -1) _items[index] = hygiene;
  }

  void delete(String id) => _items.removeWhere((h) => h.id == id);
}
