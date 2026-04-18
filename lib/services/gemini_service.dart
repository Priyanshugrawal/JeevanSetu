import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Apni API key yahan paste karo
  static const String _apiKey = 'AIzaSyDTwI2UHr6XlPGanAVBpns9cUvPY7kOvOs';

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  // Yeh function report padh ke priority decide karta hai
  Future<Map<String, String>> analyzePriority({
    required String problemType,
    required String description,
    required String location,
  }) async {
    try {
      final prompt = """
You are an AI assistant for a disaster and community relief app.
Analyze this problem report and respond ONLY in this exact format:
PRIORITY: [HIGH or MEDIUM or LOW]
REASON: [one line explanation in simple English]
SUGGESTED_SKILLS: [comma separated skills needed, e.g. Doctor, Driver]

Problem Type: $problemType
Location: $location
Description: $description

Rules:
- HIGH: flood, fire, medical emergency, earthquake, mass casualty
- MEDIUM: food shortage, water issue, shelter problem, disease outbreak
- LOW: general request, minor infrastructure, awareness campaign
""";

      final response = await _model.generateContent([
        Content.text(prompt)
      ]);

      final text = response.text ?? '';
      return _parseResponse(text);

    } catch (e) {
      // Agar Gemini fail ho toh default return karo
      return {
        'priority': 'MEDIUM',
        'reason': 'Auto-analysis unavailable',
        'skills': 'General Volunteer',
      };
    }
  }

  Map<String, String> _parseResponse(String text) {
    String priority = 'MEDIUM';
    String reason = 'Analysis complete';
    String skills = 'General Volunteer';

    for (final line in text.split('\n')) {
      if (line.startsWith('PRIORITY:')) {
        priority = line.replaceAll('PRIORITY:', '').trim();
      } else if (line.startsWith('REASON:')) {
        reason = line.replaceAll('REASON:', '').trim();
      } else if (line.startsWith('SUGGESTED_SKILLS:')) {
        skills = line.replaceAll('SUGGESTED_SKILLS:', '').trim();
      }
    }
    return {
      'priority': priority,
      'reason': reason,
      'skills': skills,
    };
  }
}