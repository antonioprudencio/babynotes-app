import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/app_user.dart';

class UserRepository {
  static const _keyUser = 'current_user';
  static const _keyLastSync = 'last_sync_at';

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUser);
    if (json != null) {
      _currentUser = AppUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  Future<void> saveUser(AppUser user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLastSync);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSync, time.toUtc().toIso8601String());
  }
}
