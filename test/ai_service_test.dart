import 'package:flutter_test/flutter_test.dart';
import 'package:local_medicine/services/ai_service.dart';

void main() {
  test('AiPredictResponse.fromJson parses suggestions', () {
    final json = {
      'input_language': 'en',
      'normalized_symptoms_en': 'fever and headache',
      'suggestions': [
        {'medicine': 'Paracetamol 500mg', 'score': 0.97},
        {'medicine': 'Dolo 650', 'score': 0.95},
      ],
    };

    final res = AiPredictResponse.fromJson(json);
    expect(res.inputLanguage, 'en');
    expect(res.normalizedSymptomsEn, 'fever and headache');
    expect(res.suggestions.length, 2);
    expect(res.suggestions.first.medicine, 'Paracetamol 500mg');
    expect(res.suggestions.first.score, closeTo(0.97, 1e-9));
  });
}
