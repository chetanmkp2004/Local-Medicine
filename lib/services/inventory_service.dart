import '../core/api_models.dart';
import 'api_client.dart';

class InventoryService {
  final ApiClient _apiClient;

  InventoryService(this._apiClient);

  Future<InventoryItemRead> updateInventory({
    required String storeId,
    required String medicineId,
    required bool available,
    int? quantity,
    double? price,
  }) async {
    final payload = InventoryItemUpdate(
      available: available,
      quantity: quantity,
      price: price,
    );
    final response = await _apiClient.dio.put(
      'inventory/$storeId/$medicineId',
      data: payload.toJson(),
    );
    return InventoryItemRead.fromJson(response.data);
  }

  Future<List<InventoryItemRead>> getStoreInventory(String storeId) async {
    final response = await _apiClient.dio.get('inventory/$storeId');
    return (response.data as List)
        .map((e) => InventoryItemRead.fromJson(e))
        .toList();
  }

  Future<List<InventoryItemRead>> bulkUpsertInventory({
    required String storeId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiClient.dio.post(
      'inventory/$storeId/bulk',
      data: {'items': items},
    );
    return (response.data as List)
        .map((e) => InventoryItemRead.fromJson(e))
        .toList();
  }
}
