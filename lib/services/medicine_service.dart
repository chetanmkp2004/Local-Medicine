import '../core/api_models.dart';
import 'api_client.dart';

class MedicineService {
  final ApiClient _apiClient;

  MedicineService(this._apiClient);

  Future<List<MedicineRead>> searchMedicines({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _apiClient.dio.get(
      'medicines/search',
      queryParameters: {'q': query, 'limit': limit, 'offset': offset},
    );
    final data = response.data;
    final list = data is Map<String, dynamic>
        ? (data['results'] as List? ?? const [])
        : (data is List ? data : const []);
    return list.map((e) => MedicineRead.fromJson(e)).toList();
  }

  Future<MedicineRead> createMedicine({
    required String nameEn,
    String? nameTe,
    String? description,
    List<String>? alternatives,
  }) async {
    final payload = MedicineCreate(
      name_en: nameEn,
      name_te: nameTe,
      description: description,
      alternatives: alternatives,
    );
    final response = await _apiClient.dio.post(
      'medicines/',
      data: payload.toJson(),
    );
    return MedicineRead.fromJson(response.data);
  }

  Future<List<MedicineRead>> listAllMedicines({int limit = 100}) async {
    final response = await _apiClient.dio.get(
      'medicines/',
      queryParameters: {'limit': limit},
    );
    return (response.data as List)
        .map((e) => MedicineRead.fromJson(e))
        .toList();
  }
}
