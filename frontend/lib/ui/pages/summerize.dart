import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:atom_mail_hf/models/email_data.dart';
import 'package:http/http.dart' as http;

class SummarizeScreen extends StatefulWidget {
  final EmailData email;
  final List<EmailData> emails;

  const SummarizeScreen({super.key, required this.email ,  required this.emails});

  @override
  State<SummarizeScreen> createState() => _SummarizeScreenState();
}

class _SummarizeScreenState extends State<SummarizeScreen> {
  late EmailData email;
  late List<EmailData> emails;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    emails = widget.emails;

    sendEmailData(emails);
  }

  Future<void> sendEmailData(List<EmailData> emails) async {
    final url = Uri.parse("https://your-api-endpoint.com/summarize");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(emails.map((e) => e.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      print("Success: ${response.body}");
    } else {
      print("Failed: ${response.statusCode}, ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subject: ${email.subject}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("From: ${email.from}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text("Content:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(email.snippet ?? "No content available", style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
