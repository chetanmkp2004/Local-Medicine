import '../core/api_models.dart';
import 'api_client.dart';

class StoreService {
  final ApiClient _apiClient;

  StoreService(this._apiClient);

  Future<List<StoreRead>> nearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
    final response = await _apiClient.dio.get(
      'stores/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
        'limit': limit,
      },
    );
    return (response.data as List).map((e) => StoreRead.fromJson(e)).toList();
  }

  Future<StoreRead> createStore({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
  }) async {
    final payload = StoreCreate(
      name: name,
      address: address,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
    );
    final response = await _apiClient.dio.post(
      'stores/',
      data: payload.toJson(),
    );
    return StoreRead.fromJson(response.data);
  }

  Future<StoreRead> updateStore({
    required String storeId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
  }) async {
    final payload = StoreCreate(
      name: name,
      address: address,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
    );
    final response = await _apiClient.dio.put(
      'stores/$storeId',
      data: payload.toJson(),
    );
    return StoreRead.fromJson(response.data);
  }

  Future<List<StoreRead>> listAllStores() async {
    final response = await _apiClient.dio.get('stores/');
    return (response.data as List).map((e) => StoreRead.fromJson(e)).toList();
  }
}
