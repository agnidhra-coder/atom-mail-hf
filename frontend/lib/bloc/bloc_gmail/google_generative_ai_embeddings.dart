// google_generative_ai_embeddings.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GoogleGenerativeAIEmbeddings {
  final String model;
  final String? apiKey;

  GoogleGenerativeAIEmbeddings({
    required this.model,
    this.apiKey,
  });

  /// Generate embeddings for a single text
  Future<List<double>> embedQuery(String text) async {
    return await _embed(text);
  }

  /// Used for embedding documents (same implementation as query for this model)
  Future<List<double>> embedDocuments(String text) async {
    return await _embed(text);
  }

  Future<List<double>> _embed(String text) async {
    final apiKey = this.apiKey ?? dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No API key provided and none found in environment variables');
    }

    // Extract the model name from the full path if needed
    final modelName = model.contains('/') ? model.split('/').last : model;

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:embedText?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['embedding']['value']);
    } else {
      throw Exception('Failed to get embedding: ${response.body}');
    }
  }
}