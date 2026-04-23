import '../../domain/models/app_user.dart';
import 'api_client.dart';

class UserApiService {
  final ApiClient _client;
  UserApiService(this._client);

  Future<AppUser> createOrFetch(String name, String email) async {
    final data = await _client.post('/api/users', {'name': name, 'email': email});
    final json = data as Map<String, dynamic>;
    return AppUser(id: json['id'] as String, name: json['name'] as String, email: json['email'] as String);
  }
}
