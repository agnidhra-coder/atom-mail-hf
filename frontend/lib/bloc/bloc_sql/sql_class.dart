import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SqlManage {
  late Directory _appDocDir;
  late SharedPreferences _prefs;
  late GenerativeModel _embeddingModel;
  final String _collectionName = "gmail";
  final Uuid _uuid = Uuid();

  Future<void> initialize() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _prefs = await SharedPreferences.getInstance();
    _embeddingModel = GenerativeModel(model: 'models/text-embedding-004', apiKey: dotenv.env['GEMINI_API_KEY']!);

    // Create the collection directory if it doesn't exist
    final collectionDir = Directory('${_appDocDir.path}/$_collectionName');
    if (!await collectionDir.exists()) {
      await collectionDir.create(recursive: true);
    }

    dotenv.load(fileName:'.env');
  }

  Future<void> addToDatabase(List<Map<String, dynamic>> emails) async {
    final lastMailTime = _prefs.getDouble('LAST_MAIL_TIME') ?? 0;
    double latestTime = lastMailTime;

    for (var email in emails) {
      if (email['metadata']['timestamp'] > lastMailTime) {
        final emailContent = _maskSensitive(email['content']);
        final embedding = await getEmbedding(emailContent);
        final docId = _uuid.v4();

        await _saveDocument(docId, emailContent, email['metadata'], embedding);

        if (email['metadata']['timestamp'] > latestTime) {
          latestTime = email['metadata']['timestamp'];
        }
      }
    }

    if (latestTime > lastMailTime) {
      await _prefs.setDouble('LAST_MAIL_TIME', latestTime);
    }
  }

  // Future<void> _saveDocument(String id, String content, Map<String, dynamic> metadata, List<double> embedding) async {
  //   final docFile = File('${_appDocDir.path}/$_collectionName/$id.json');
  //   final docData = {
  //     'content': content,
  //     'metadata': metadata,
  //     'embedding': embedding,
  //   };
  //   await docFile.writeAsString(jsonEncode(docData));
  // }

  Future<void> _saveDocument(String id, String content, Map<String, dynamic> metadata, List<double> embedding) async {
    final url = Uri.parse('https://great-jobs-rest.loca.lt/email/upload');

    print(metadata.toString());

    final docData = {
      'content': content,
      'metadata': metadata,
      'embedding': embedding,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(docData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Success: ${response.body}');
    } else {
      print('Failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  }


  Future<List<double>> getEmbedding(String text) async {
    try {
      // Create a single Content object with the text
      final content = Content.text(text);

      // Call embedContent with a single Content object
      final result = await _embeddingModel.embedContent(content);

      // Extract the embedding values from the response
      return result.embedding.values;
    } catch (e) {
      print("[ERROR] Failed to generate embedding: $e");
      // Return a default embedding in case of error
      return List.filled(512, 0.0);
    }
  }


  String _maskSensitive(String email) {
    // Implement your sensitive data masking logic here
    // For simplicity, this example doesn't implement actual masking
    return email;
  }
}
