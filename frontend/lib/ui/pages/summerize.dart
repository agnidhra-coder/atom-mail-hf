import 'dart:convert';

import 'package:atom_mail_hf/ui/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:atom_mail_hf/models/email_data.dart';
import 'package:http/http.dart' as http;

import 'compose.dart';

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
  String name = '';
  String emailID = '';

  @override
  void initState() {
    super.initState();
    email = widget.email;
    emails = widget.emails;

    String rawEmail = email.from;

    RegExp exp = RegExp(r'^(.*)<(.*)>$');
    Match? match = exp.firstMatch(rawEmail);
    if (match != null) {
      name = match.group(1)!.trim();
      emailID = match.group(2)!.trim();
    } else {
      print("Invalid format");
    }

    // sendEmailData(emails);
  }
  //
  // Future<void> sendEmailData(List<EmailData> emails) async {
  //   final url = Uri.parse("https://your-api-endpoint.com/summarize");
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(emails.map((e) => e.toJson()).toList()),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print("Success: ${response.body}");
  //   } else {
  //     print("Failed: ${response.statusCode}, ${response.body}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${email.subject}", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              Wrap(
                children: [
                  Text("From:  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(name , style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 8),
              Text(emailID , style: TextStyle(fontSize: 16)),
              SizedBox(height: 15),
              Text("Content:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(email.snippet ?? "No content available", style: TextStyle(fontSize: 14)),
              SizedBox(height: 20,),
              Text("Summary:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("YAHA HOGI SUMMARY"?? "No content available", style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: 'Reply',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Compose(email: email, isReply: true,),
              ),
            );
          },
        ),
      ),
    );
  }
}
