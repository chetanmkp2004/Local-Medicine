import '../core/api_models.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Token> register({
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    final payload = UserRegisterRequest(
      email: email,
      password: password,
      full_name: fullName,
      phone: phone,
      role: role,
    );
    final response = await _apiClient.dio.post(
      'auth/register',
      data: payload.toJson(),
    );
    final token = Token.fromJson(response.data);
    await _apiClient.saveTokens(token.access_token, token.refresh_token);
    return token;
  }

  Future<Token> login({required String email, required String password}) async {
    final payload = UserLoginRequest(email: email, password: password);
    final response = await _apiClient.dio.post(
      'auth/login',
      data: payload.toJson(),
    );
    final token = Token.fromJson(response.data);
    await _apiClient.saveTokens(token.access_token, token.refresh_token);
    return token;
  }

  Future<UserRead> me() async {
    final response = await _apiClient.dio.get('auth/me');
    return UserRead.fromJson(response.data);
  }

  Future<void> logout() async {
    await _apiClient.clearTokens();
  }
}
