import '../../domain/models/weight_record.dart';
import 'api_client.dart';

class WeightRecordApiService {
  final ApiClient _client;
  WeightRecordApiService(this._client);

  Future<List<WeightRecord>> fetchByBaby(String babyId, {DateTime? updatedSince}) async {
    final params = <String, String>{'babyId': babyId};
    if (updatedSince != null) params['updatedSince'] = updatedSince.toUtc().toIso8601String();
    final data = await _client.get('/api/weight-records', params: params);
    return (data as List).map((j) => WeightRecord.fromApi(j as Map<String, dynamic>)).toList();
  }

  Future<WeightRecord> create(WeightRecord record) async {
    final data = await _client.post('/api/weight-records', record.toApiJson());
    return WeightRecord.fromApi(data as Map<String, dynamic>);
  }

  Future<WeightRecord> update(WeightRecord record) async {
    final data = await _client.put('/api/weight-records/${record.id}', record.toApiJson());
    return WeightRecord.fromApi(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _client.delete('/api/weight-records/$id');
}
