import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config.dart';

class AiSuggestion {
  final String medicine;
  final double score;

  AiSuggestion({required this.medicine, required this.score});

  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    return AiSuggestion(
      medicine: json['medicine'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}

class AiPredictResponse {
  final String inputLanguage;
  final String normalizedSymptomsEn;
  final List<AiSuggestion> suggestions;

  AiPredictResponse({
    required this.inputLanguage,
    required this.normalizedSymptomsEn,
    required this.suggestions,
  });

  factory AiPredictResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['suggestions'] as List<dynamic>? ?? [];
    return AiPredictResponse(
      inputLanguage: json['input_language'] as String? ?? 'en',
      normalizedSymptomsEn: json['normalized_symptoms_en'] as String? ?? '',
      suggestions: raw
          .map((e) => AiSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AiService {
  late final Dio _dio;

  AiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.aiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
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
          logPrint: (obj) => debugPrint('🤖 AI: $obj'),
        ),
      );
    }
  }

  Future<bool> health() async {
    try {
      debugPrint('🏥 Checking AI health at ${ApiConfig.aiBaseUrl}/health');
      final res = await _dio.get('health');
      debugPrint('✅ AI health OK: ${res.data}');
      return (res.data is Map && res.data['status'] == 'ok');
    } catch (e) {
      debugPrint('❌ AI health check failed: $e');
      return false;
    }
  }

  Future<AiPredictResponse> predictMedicine({required String symptoms}) async {
    debugPrint('🔮 Predicting medicine for symptoms: $symptoms');
    debugPrint('   AI Base URL: ${ApiConfig.aiBaseUrl}');

    final res = await _dio.post(
      'predict_medicine',
      data: {'symptoms': symptoms},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    debugPrint('✅ AI prediction received: ${res.data}');
    return AiPredictResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
