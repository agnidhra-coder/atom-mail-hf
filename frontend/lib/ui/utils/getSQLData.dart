import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> getSQLData() async {
  final url = Uri.parse('https://great-jobs-rest.loca.lt/email/download');
  List<Map<String, dynamic>> dataList = [];

  try {
    final response = await http.get(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      dataList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      print(' Success: ${response.body}');
    } else {
      print(' Failed with status: ${response.statusCode}');
      // print('Response: ${response.body}');
    }
  } catch (e) {
    print(' Exception caught: $e');
  }

  return dataList;
}
