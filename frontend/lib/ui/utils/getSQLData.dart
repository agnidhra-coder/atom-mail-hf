import 'dart:convert';

import 'package:atom_mail_hf/models/email_data.dart';
import 'package:http/http.dart' as http;

final _baseUrl = 'https://chilly-jobs-peel.loca.lt/email/download';

Future<List<Map<String, dynamic>>> getSQLData() async {
  final url = Uri.parse(_baseUrl);
  try {
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('❌ Failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('❗ Exception caught in getSQLData: $e');
  }
  return [];
}


Future<List<String>> getTags() async {
  final url = Uri.parse(_baseUrl);
  Set<String> uniqueTags = {};

  try {
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<Map<String, dynamic>> dataList =
      List<Map<String, dynamic>>.from(jsonDecode(response.body));

      for (var item in dataList) {
        var tagList = item['metadata']?['tags'];
        if (tagList is List) {
          uniqueTags.addAll(tagList.map((tag) => tag.toString()));
        }
      }
    } else {
      print('❌ Failed to fetch tags. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('❗ Exception caught in getTags: $e');
  }

  return uniqueTags.toList();
}



Future<List<EmailData>> getTagMail(String tag) async {
  final url = Uri.parse(_baseUrl);
  List<EmailData> filteredEmails = [];

  try {
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataList = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      for (var item in dataList) {
        final tags = item['metadata']?['tags'];
        if (tags != null && tags.contains(tag)) {
          final email = EmailData.fromJsonWithContent(
            json: item,
            id: "null",
          );
          filteredEmails.add(email);
        }
      }
    } else {
      print('❌ Failed to get tag mail: ${response.statusCode}');
    }
  } catch (e) {
    print('❗ Exception in getTagMail: $e');
  }

  return filteredEmails;
}

Future<String> getSummary(String query) async{
  final url = Uri.parse('https://4e6e-2409-40e4-52-ccce-448e-a831-66cf-2300.ngrok-free.app/summarize?thread_id=$query');
  String summary = '';

  try {
    final response = await http.get(
      url,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      summary = response.body;
      print(' Success: ${response.body}');
    } else {
      print(' Failed with status: ${response.statusCode}');
      // print('Response: ${response.body}');
    }
  } catch (e) {
    print(' Exception caught: $e');
  }

  return summary;
}
