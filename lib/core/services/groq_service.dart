import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../features/ai_assistant/models/chat_message.dart';

/// Talks to Groq's OpenAI-compatible chat completions API.
///
/// The API key and model name are read from the `config/groq` document in
/// Firestore (fields `apiKey`, `model`) rather than bundled with the app, so
/// they can be rotated without a release. Falls back to a default model if
/// Firestore doesn't specify one — Llama 4 Scout understands both plain text
/// and images in the same endpoint, which covers the "chat" and "analyze my
/// room photo" cases the AI Assistant screen needs.
class GroqService {
  GroqService._();
  static final GroqService instance = GroqService._();

  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _defaultModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

  static const _systemPrompt =
      'You are the Vana AI assistant, embedded in a sustainable interior '
      'design app for Indian homes. You help people choose low-carbon, '
      'low-VOC materials, air-purifying plants, and biophilic layouts for '
      'their rooms. When shown a photo of a room, describe what you see and '
      'suggest specific sustainable materials, finishes and plants that '
      'would suit it, and rough cost expectations in INR when useful. Keep '
      'answers warm, concise and practical — short paragraphs or bullet '
      'points, not walls of text.';

  String _apiKey = '';
  String _model = _defaultModel;
  Future<void>? _configLoad;

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Fetches the Groq config document once and caches it in memory for the
  /// rest of the app session.
  Future<void> _ensureConfig() {
    return _configLoad ??= FirebaseFirestore.instance
        .collection('config')
        .doc('groq')
        .get()
        .then((snap) {
      final data = snap.data();
      _apiKey = (data?['apiKey'] as String?)?.trim() ?? '';
      final model = (data?['model'] as String?)?.trim();
      if (model != null && model.isNotEmpty) _model = model;
    });
  }

  /// Sends [prompt] (optionally with a photo attached as [imageBytes]) along
  /// with the prior [history] for context, and returns the assistant's reply.
  Future<String> chat({
    required List<ChatMessage> history,
    required String prompt,
    Uint8List? imageBytes,
  }) async {
    await _ensureConfig();
    if (!isConfigured) {
      throw const GroqException(
        'The AI assistant is not configured yet. Add a GROQ_API_KEY to the '
        'config/groq document in Firestore to enable it.',
      );
    }

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _systemPrompt},
      for (final m in history)
        {'role': m.role == ChatRole.assistant ? 'assistant' : 'user', 'content': m.text},
    ];

    if (imageBytes != null) {
      final b64 = base64Encode(imageBytes);
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt.isEmpty ? 'What do you notice about this room?' : prompt},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$b64'},
          },
        ],
      });
    } else {
      messages.add({'role': 'user', 'content': prompt});
    }

    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': 0.6,
              'max_tokens': 1024,
            }),
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const GroqException('Could not reach Groq. Check your internet connection and try again.');
    }

    if (response.statusCode != 200) {
      String detail = 'Groq request failed (${response.statusCode}).';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final message = body['error']?['message'];
        if (message is String && message.isNotEmpty) detail = message;
      } catch (_) {
        // Keep the generic message above.
      }
      throw GroqException(detail);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    Object? content;
    if (choices != null && choices.isNotEmpty) {
      final message = choices.first['message'] as Map<String, dynamic>?;
      content = message?['content'];
    }
    if (content is! String || content.trim().isEmpty) {
      throw const GroqException('Groq returned an empty response. Please try again.');
    }
    return content.trim();
  }
}

class GroqException implements Exception {
  final String message;
  const GroqException(this.message);

  @override
  String toString() => message;
}
