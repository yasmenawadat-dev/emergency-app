import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'YOUR_API_KEY';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> askAI(String prompt) async {
    final response = await _model.generateContent(
      [Content.text(prompt)],
    );

    return response.text ?? 'لا يوجد رد';
  }
}
