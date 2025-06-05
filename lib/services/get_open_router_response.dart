import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> getOpenRouterResponse(String userInput) async {
  const url = 'https://openrouter.ai/api/v1/chat/completions';
  const apiKey =
      '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'; // ✅ Replace with your working key

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "model": "openai/gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": userInput},
    ],
    "max_tokens": 100,
    "temperature": 0.7,
  });

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );

  print('📦 Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // ✅ Null-safe access to choices
    if (data['choices'] != null && data['choices'].isNotEmpty) {
      return data['choices'][0]['message']['content'] ?? 'No content';
    } else {
      return '⚠️ No response choices received.';
    }
  } else {
    throw Exception('Failed to get response: ${response.body}');
  }
}
