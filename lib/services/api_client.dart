import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../core/config.dart';

class ApiClient {
  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  ApiClient() {
    _storage = const FlutterSecureStorage();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiV1,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('🌐 DIO: $obj'),
        ),
      );
    }

    // Add interceptor to attach auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint(
            '🚀 API Request: ${options.method} ${options.baseUrl}${options.path}',
          );
          return handler.next(options);
        },
        onError: (error, handler) async {
          debugPrint(
            '❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          debugPrint('   Message: ${error.message}');

          if (error.response?.statusCode == 401) {
            // Token likely expired, try to refresh
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final response = await _dio.post(
                  '${ApiConfig.apiV1}/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );
                final newAccessToken = response.data['access_token'];
                await _storage.write(
                  key: 'access_token',
                  value: newAccessToken,
                );

                // Retry original request
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';

                final newResponse = await _dio.request(
                  opts.path,
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                    responseType: opts.responseType,
                    contentType: opts.contentType,
                  ),
                );
                return handler.resolve(newResponse);
              } catch (e) {
                // Refresh failed; logout user
                await clearTokens();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
}
