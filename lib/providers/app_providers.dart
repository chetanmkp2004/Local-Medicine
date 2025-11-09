import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/store_service.dart';
import '../services/medicine_service.dart';
import '../services/inventory_service.dart';
import '../services/request_service.dart';
import '../services/ai_service.dart';
import '../core/api_models.dart';

// API Client provider
final apiClientProvider = Provider((ref) => ApiClient());

// Service providers
final authServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

final storeServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StoreService(apiClient);
});

final medicineServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MedicineService(apiClient);
});

final inventoryServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InventoryService(apiClient);
});

final requestServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RequestService(apiClient);
});

// AI service provider
final aiServiceProvider = Provider((ref) {
  return AiService();
});

/// AI health check provider
/// - true: healthy
/// - false: unhealthy or unreachable
/// Auto-disposes to keep it lightweight; UI can refresh on demand.
final aiHealthProvider = FutureProvider.autoDispose<bool>((ref) async {
  final ai = ref.watch(aiServiceProvider);
  return ai.health();
});

// Auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Stores nearby
final nearbyStoresProvider =
    FutureProvider.family<
      List<StoreRead>,
      ({double lat, double lon, double radius})
    >((ref, params) async {
      final storeService = ref.watch(storeServiceProvider);
      return storeService.nearbyStores(
        latitude: params.lat,
        longitude: params.lon,
        radiusKm: params.radius,
      );
    });

// Medicine search
final medicineSearchProvider =
    FutureProvider.family<List<MedicineRead>, String>((ref, query) async {
      final medicineService = ref.watch(medicineServiceProvider);
      return medicineService.searchMedicines(query: query);
    });

// Customer requests
final customerRequestsProvider = FutureProvider((ref) async {
  final requestService = ref.watch(requestServiceProvider);
  return requestService.getCustomerRequests();
});

// Shop requests
final shopRequestsProvider = FutureProvider((ref) async {
  final requestService = ref.watch(requestServiceProvider);
  return requestService.getShopRequests();
});

// Auth state model
class AuthState {
  final bool isLoading;
  final UserRead? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserRead? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<void> register({
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.register(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        phone: phone,
      );
      final user = await _authService.me();
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.login(email: email, password: password);
      final user = await _authService.me();
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }
}
