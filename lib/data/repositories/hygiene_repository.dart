import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/hygiene.dart';

class HygieneRepository {
  static const _key = 'hygiene';
  final List<Hygiene> _items = [];

  List<Hygiene> getAll() => List.unmodifiable(_items);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    _items.clear();
    _items.addAll(jsonList.map((s) => Hygiene.fromJson(jsonDecode(s) as Map<String, dynamic>)));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _items.map((h) => jsonEncode(h.toJson())).toList());
  }

  void add(Hygiene hygiene) {
    _items.add(hygiene);
    _save();
  }

  void update(Hygiene hygiene) {
    final index = _items.indexWhere((h) => h.id == hygiene.id);
    if (index != -1) {
      _items[index] = hygiene;
      _save();
    }
  }

  void delete(String id) {
    _items.removeWhere((h) => h.id == id);
    _save();
  }
}
