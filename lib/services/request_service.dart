import '../core/api_models.dart';
import 'api_client.dart';

class RequestService {
  final ApiClient _apiClient;

  RequestService(this._apiClient);

  Future<RequestRead> createRequest({
    required String medicineId,
    String? storeId,
  }) async {
    final payload = RequestCreate(medicine_id: medicineId, store_id: storeId);
    final response = await _apiClient.dio.post(
      'requests/',
      data: payload.toJson(),
    );
    return RequestRead.fromJson(response.data);
  }

  Future<List<RequestRead>> getCustomerRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _apiClient.dio.get(
      'requests/my',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data as List).map((e) => RequestRead.fromJson(e)).toList();
  }

  Future<List<RequestRead>> getShopRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _apiClient.dio.get(
      'requests/shop',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data as List).map((e) => RequestRead.fromJson(e)).toList();
  }

  Future<RequestRead> approveRequest(String requestId) async {
    final payload = RequestUpdate(status: 'approved');
    final response = await _apiClient.dio.put(
      'requests/$requestId',
      data: payload.toJson(),
    );
    return RequestRead.fromJson(response.data);
  }

  Future<RequestRead> rejectRequest(String requestId) async {
    final payload = RequestUpdate(status: 'rejected');
    final response = await _apiClient.dio.put(
      'requests/$requestId',
      data: payload.toJson(),
    );
    return RequestRead.fromJson(response.data);
  }

  Future<RequestRead> completeRequest(String requestId) async {
    final payload = RequestUpdate(status: 'completed');
    final response = await _apiClient.dio.put(
      '/requests/$requestId',
      data: payload.toJson(),
    );
    return RequestRead.fromJson(response.data);
  }

  Future<List<RequestRead>> getAllRequests({
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _apiClient.dio.get(
      'requests/',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data as List).map((e) => RequestRead.fromJson(e)).toList();
  }
}
