import '../../domain/models/meal.dart';
import 'api_client.dart';

class MealApiService {
  final ApiClient _client;
  MealApiService(this._client);

  Future<List<Meal>> fetchByBaby(String babyId, {DateTime? updatedSince}) async {
    final params = <String, String>{'babyId': babyId};
    if (updatedSince != null) params['updatedSince'] = updatedSince.toUtc().toIso8601String();
    final data = await _client.get('/api/meals', params: params);
    return (data as List).map((j) => Meal.fromApi(j as Map<String, dynamic>)).toList();
  }

  Future<Meal> create(Meal meal) async {
    final data = await _client.post('/api/meals', meal.toApiJson());
    return Meal.fromApi(data as Map<String, dynamic>);
  }

  Future<Meal> update(Meal meal) async {
    final data = await _client.put('/api/meals/${meal.id}', meal.toApiJson());
    return Meal.fromApi(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _client.delete('/api/meals/$id');
}
