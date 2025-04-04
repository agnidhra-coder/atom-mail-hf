import 'package:atom_mail_hf/models/email_data.dart';
import 'package:atom_mail_hf/ui/pages/compose.dart';
import 'package:atom_mail_hf/ui/pages/summerize.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  final List<EmailData> emails;

  const HomePage({super.key, required this.emails});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final List<EmailData> emails;
  String name = '';
  String emailID = '';
  @override
  void initState() {
    super.initState();
    emails = widget.emails;
  }
  final List<String> tags = ['All', 'Work', 'Personal', 'Important', 'Starred'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atom Mail'),
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags Row
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              separatorBuilder: (context, index) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Chip(
                    label: Text(
                      tags[index],
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isSelected ? Colors.black26 : Colors.transparent,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 10),

          // Emails List
          Expanded(
            child: ListView.builder(
              itemCount: emails.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                String rawEmail = emails[index].from;

                RegExp exp = RegExp(r'^(.*)<(.*)>$');
                Match? match = exp.firstMatch(rawEmail);
                if (match != null) {
                  name = match.group(1)!.trim();
                  emailID = match.group(2)!.trim();
                } else {
                  print("Invalid format");
                }
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(emails[index].subject ?? 'Unknown'),
                    titleAlignment: ListTileTitleAlignment.center,
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    subtitle: Align(alignment: Alignment.bottomLeft, child: Text(name ?? 'Unknown'),),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummarizeScreen(email: emails[index], emails: emails,),
                        ),
                      );
                    },
                  ),
                );

              },
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Compose(),
            ),
          );
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
