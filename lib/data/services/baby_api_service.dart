import '../../domain/models/baby.dart';
import 'api_client.dart';

class BabyApiService {
  final ApiClient _client;
  BabyApiService(this._client);

  Future<List<Baby>> fetchAll(String userId, {DateTime? updatedSince}) async {
    final params = <String, String>{};
    if (updatedSince != null) params['updatedSince'] = updatedSince.toUtc().toIso8601String();
    final data = await _client.get('/api/babies', userId: userId, params: params);
    return (data as List).map((j) => Baby.fromApi(j as Map<String, dynamic>)).toList();
  }

  Future<Baby> create(Baby baby, String userId) async {
    final data = await _client.post('/api/babies', baby.toApiJson(), userId: userId);
    return Baby.fromApi(data as Map<String, dynamic>);
  }

  Future<Baby> update(Baby baby) async {
    final data = await _client.put('/api/babies/${baby.id}', baby.toApiJson());
    return Baby.fromApi(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _client.delete('/api/babies/$id');

  Future<void> share(String babyId, String email) =>
      _client.post('/api/babies/$babyId/access', {'email': email});
}
