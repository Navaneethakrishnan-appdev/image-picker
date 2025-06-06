import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> getOpenRouterResponse(String userInput) async {
  const url = 'https://openrouter.ai/api/v1/chat/completions';
  const apiKey =
      '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';

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://your-app-domain.com', // Required by OpenRouter
    'X-Title': 'Yoga and Fitness Trainer', // Optional: Your app name
  };

  final body = jsonEncode({
    "model": "openai/gpt-4o-mini",
    "messages": [
      {
        "role": "system",
        "content":
            "You are a yoga and fitness assistant. You should ONLY answer questions related to yoga, fitness, food, exercise, health, and wellness. If asked about any other topics, politely respond that you can only help with yoga and fitness related questions. Keep your responses concise and focused on practical advice."
      },
      {"role": "user", "content": userInput},
    ],
    "max_tokens": 100,
    "temperature": 0.7,
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('📦 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'] ?? 'No content';
      } else {
        return '⚠️ No response choices received.';
      }
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage =
          errorData['error']?['message'] ?? 'Unknown error occurred';
      throw Exception('API Error: $errorMessage');
    }
  } catch (e) {
    print('❌ Error in getOpenRouterResponse: $e');
    return 'Sorry, I encountered an error. Please try again later.';
  }
}
