import 'package:atom_mail_hf/models/email_data.dart';
import 'package:atom_mail_hf/ui/utils/custom_button.dart';
import 'package:flutter/material.dart';

class Compose extends StatefulWidget {
  late EmailData? email;
  final bool isReply;

  Compose({super.key, this.email , this.isReply = false});

  @override
  State<Compose> createState() => _ComposeState();
}

class _ComposeState extends State<Compose> {
  late final EmailData email;
  late final bool isReply;
  late final TextEditingController _toController;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  String name = '';
  String emailID = '';

  @override
  void initState() {
    isReply = widget.isReply;
    _subjectController = TextEditingController();
    _bodyController = TextEditingController();

    if (isReply) {
      email = widget.email!;
      String rawEmail = email.from;
      RegExp exp = RegExp(r'^(.*)<(.*)>$');
      Match? match = exp.firstMatch(rawEmail);
      if (match != null) {
        name = match.group(1)!.trim();
        emailID = match.group(2)!.trim();
      }
      _subjectController.text = "Re: ${email.subject}";
    }

    _toController = TextEditingController(text: isReply ? emailID : '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compose',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[800]),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // To Field
              TextField(
                controller: _toController,
                enabled: !isReply,
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 16),

              // Subject Field
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 16),

              // Message Body
              TextField(
                controller: _bodyController,
                minLines: 8,
                maxLines: 15,
                decoration: InputDecoration(
                  labelText: 'Compose email',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
                style: TextStyle(color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: ElevatedButton(
          onPressed: () {
            // Handle send
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue[700],
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Send'),
        ),
      ),
    );
  }
}
