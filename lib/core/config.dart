import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration with platform-aware base URLs.
class ApiConfig {
  // Optional overrides via --dart-define
  static const String _envBackendBase = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: '',
  );
  static const String _envAiBase = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: '',
  );

  /// Resolve backend base URL depending on platform and env overrides.
  static String get baseUrl {
    if (_envBackendBase.isNotEmpty) return _envBackendBase;

    if (kIsWeb) {
      // Use the same host the app is served from; default port 8000
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      final port = Uri.base.hasPort ? Uri.base.port : 8000;
      return 'http://$host:$port';
    }

    try {
      if (Platform.isAndroid) {
        // Check if it's a physical device by looking for emulator indicators
        // Physical devices won't have "emulator" in environment or won't be localhost
        // For physical devices, you MUST use --dart-define=BACKEND_BASE_URL=http://YOUR_PC_IP:8000
        // Otherwise, it defaults to emulator IP (10.0.2.2)
        final isEmulator =
            Platform.environment['ANDROID_EMULATOR'] == 'true' ||
            Platform.localHostname.contains('localhost');

        if (isEmulator) {
          // Android emulator loopback to host machine
          return 'http://10.0.2.2:8000';
        } else {
          // Physical device: MUST set via --dart-define or it won't work
          // This is a fallback that will likely fail - user should use dart-define
          return 'http://192.168.1.100:8000'; // Placeholder - will likely fail
        }
      }
    } catch (_) {
      // dart:io Platform may not be available in some contexts
    }

    // Desktop (Windows/macOS/Linux) and iOS simulator
    return 'http://localhost:8000';
  }

  /// API v1 root (with trailing slash for Dio path concatenation)
  static String get apiV1 => '$baseUrl/api/v1/';

  /// AI service base URL
  static String get aiBaseUrl {
    if (_envAiBase.isNotEmpty) return _envAiBase;

    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      final port = 8001;
      return 'http://$host:$port';
    }

    try {
      if (Platform.isAndroid) {
        // Check if emulator vs physical device
        final isEmulator = Platform.environment['ANDROID_EMULATOR'] == 'true' ||
                          Platform.localHostname.contains('localhost');
        
        if (isEmulator) {
          return 'http://10.0.2.2:8001';
        } else {
          // Physical device: use dart-define or fallback (will likely fail)
          return 'http://192.168.1.100:8001';
        }
      }
    } catch (_) {}

    return 'http://localhost:8001';
  }

  // Convenience endpoint getters (not strictly required by services using relative paths)
  static String get aiHealth => '$aiBaseUrl/health';
  static String get aiPredictMedicine => '$aiBaseUrl/predict_medicine';

  static String get authRegister => '$apiV1/auth/register';
  static String get authLogin => '$apiV1/auth/login';
  static String get authRefresh => '$apiV1/auth/refresh';
  static String get authMe => '$apiV1/auth/me';

  static String get stores => '$apiV1/stores';
  static String get storesNearby => '$apiV1/stores/nearby';

  static String get medicines => '$apiV1/medicines';
  static String get medicinesSearch => '$apiV1/medicines/search';

  static String get inventory => '$apiV1/inventory';

  static String get requests => '$apiV1/requests';
}
