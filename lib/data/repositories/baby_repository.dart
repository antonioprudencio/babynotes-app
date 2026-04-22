import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/baby.dart';

class BabyRepository {
  static const _key = 'babies';
  final List<Baby> _babies = [];

  List<Baby> getAll() => List.unmodifiable(_babies);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    _babies.clear();
    _babies.addAll(jsonList.map((s) => Baby.fromJson(jsonDecode(s) as Map<String, dynamic>)));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _babies.map((b) => jsonEncode(b.toJson())).toList());
  }

  void add(Baby baby) {
    _babies.add(baby);
    _save();
  }

  void update(Baby baby) {
    final index = _babies.indexWhere((b) => b.id == baby.id);
    if (index != -1) {
      _babies[index] = baby;
      _save();
    }
  }

  void delete(String id) {
    _babies.removeWhere((b) => b.id == id);
    _save();
  }
}
