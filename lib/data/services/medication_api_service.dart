import '../../domain/models/medication.dart';
import 'api_client.dart';

class MedicationApiService {
  final ApiClient _client;
  MedicationApiService(this._client);

  Future<List<Medication>> fetchByBaby(String babyId, {DateTime? updatedSince}) async {
    final params = <String, String>{'babyId': babyId};
    if (updatedSince != null) params['updatedSince'] = updatedSince.toUtc().toIso8601String();
    final data = await _client.get('/api/medications', params: params);
    return (data as List).map((j) => Medication.fromApi(j as Map<String, dynamic>)).toList();
  }

  Future<Medication> create(Medication medication) async {
    final data = await _client.post('/api/medications', medication.toApiJson());
    return Medication.fromApi(data as Map<String, dynamic>);
  }

  Future<Medication> update(Medication medication) async {
    final data = await _client.put('/api/medications/${medication.id}', medication.toApiJson());
    return Medication.fromApi(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _client.delete('/api/medications/$id');
}
