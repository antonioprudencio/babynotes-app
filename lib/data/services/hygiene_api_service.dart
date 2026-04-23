import '../../domain/models/hygiene.dart';
import 'api_client.dart';

class HygieneApiService {
  final ApiClient _client;
  HygieneApiService(this._client);

  Future<List<Hygiene>> fetchByBaby(String babyId, {DateTime? updatedSince}) async {
    final params = <String, String>{'babyId': babyId};
    if (updatedSince != null) params['updatedSince'] = updatedSince.toUtc().toIso8601String();
    final data = await _client.get('/api/hygiene', params: params);
    return (data as List).map((j) => Hygiene.fromApi(j as Map<String, dynamic>)).toList();
  }

  Future<Hygiene> create(Hygiene hygiene) async {
    final data = await _client.post('/api/hygiene', hygiene.toApiJson());
    return Hygiene.fromApi(data as Map<String, dynamic>);
  }

  Future<Hygiene> update(Hygiene hygiene) async {
    final data = await _client.put('/api/hygiene/${hygiene.id}', hygiene.toApiJson());
    return Hygiene.fromApi(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _client.delete('/api/hygiene/$id');
}
