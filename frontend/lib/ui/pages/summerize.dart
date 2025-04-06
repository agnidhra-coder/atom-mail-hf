import 'dart:convert';

import 'package:atom_mail_hf/ui/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:atom_mail_hf/models/email_data.dart';

import '../utils/AIReplyBottomSheet.dart';
import '../utils/getSQLData.dart';
import 'compose.dart';

class SummarizeScreen extends StatefulWidget {
  final EmailData email;
  final List<EmailData> emails;

  const SummarizeScreen({super.key, required this.email, required this.emails});

  @override
  State<SummarizeScreen> createState() => _SummarizeScreenState();
}

class _SummarizeScreenState extends State<SummarizeScreen> {
  late EmailData email;
  late List<EmailData> emails;
  String name = '';
  String emailID = '';
  String summary = 'Fetching Summary...';

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
    }

    print("email.threadid: ${email.threadId}");
    print("email.tags: ${email.tags}");
    print("email.emailid: ${emailID}");

    getSummary(email.threadId).then((value) {
      setState(() {
        summary = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Summary',
          style: TextStyle(color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Summary Box
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text(
                          "AI Summary",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      summary,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),

              // Email Subject
              Text(
                "${email.subject}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              SizedBox(height: 15),

              // From Section
              Row(
                children: [
                  Text("From:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  SizedBox(width: 4),
                  Flexible(
                      child: Text(name,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                ],
              ),
              SizedBox(height: 8),

              // Email ID
              Text(emailID, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 15),

              // Content Section
              Text("Content:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!)),
                child: Text(email.snippet ?? "No content available",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar with AI Reply Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // print(email.threadId);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) => AIReplyBottomSheet(email),
            );
          },
          icon: Icon(Icons.auto_awesome),
          label: Text("Reply with AI"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue[700],
            backgroundColor: Colors.blue[100],
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}

