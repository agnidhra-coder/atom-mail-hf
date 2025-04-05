import 'package:atom_mail_hf/models/email_data.dart';
import 'package:atom_mail_hf/ui/pages/home.dart';
import 'package:atom_mail_hf/ui/utils/custom_input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/slides/v1.dart';

import '../utils/custom_button.dart';

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
  String name = '';
  String emailID = '';

  @override
  void initState() {
    isReply = widget.isReply;

    if(isReply){
      email = widget.email!;
      String rawEmail = email.from;
      RegExp exp = RegExp(r'^(.*)<(.*)>$');
      Match? match = exp.firstMatch(rawEmail);
      if (match != null) {
        name = match.group(1)!.trim();
        emailID = match.group(2)!.trim();
      } else {
        print("Invalid format");
      }
    }
    _toController = isReply
        ? TextEditingController(text: emailID)
        : TextEditingController(text: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose'),
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: CustomInputField(
                controller: _toController,
                hintText: 'To',
                icon: Icons.email,
                isEnabled: isReply,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: 'SEND',
          onPressed: () {
            
          },
        ),
      ),
    );
  }
}
