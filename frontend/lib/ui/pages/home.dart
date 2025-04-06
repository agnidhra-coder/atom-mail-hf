import 'package:atom_mail_hf/models/email_data.dart';
import 'package:atom_mail_hf/ui/pages/compose.dart';
import 'package:atom_mail_hf/ui/pages/summerize.dart';
import 'package:atom_mail_hf/ui/utils/getSQLData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../bloc/bloc_sql/sql_bloc.dart';
import '../../bloc/bloc_sql/sql_event.dart';

class HomePage extends StatefulWidget {
  final List<EmailData> emails;

  const HomePage({super.key, required this.emails});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<EmailData> emails = [];
  String name = '';
  String emailID = '';
  List<String> tags = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emails = widget.emails;
    fetchTags();
    // extractUniqueTags(widget.emails);
  }

  // void extractUniqueTags(List<EmailData> emailsList) {
  //   final Set<String> tagSet = {};
  //   for (var email in emailsList) {
  //     tagSet.addAll(email.tags);
  //     print(email.tags);
  //   }
  //
  //   final List<String> uniqueTags = tagSet.toList()..sort();
  //   setState(() {
  //     tags = ['All', ...uniqueTags];
  //   });
  // }
  //
  // List<EmailData> getEmailsByTag(List<EmailData> emails, String tag) {
  //   if (tag == 'All') return emails;
  //
  //   return emails.where((email) => email.tags.contains(tag)).toList();
  // }


  Future<void> fetchTags() async {
    final fetchedTags = await getTags();
    setState(() {
      tags = fetchedTags;
      tags.insert(0, 'All');
    });
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Atom Mail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.grey[800], // Darker title text
          ),
        ),
        backgroundColor: Colors.grey[50], // Very light background
        elevation: 0, // Remove shadow
        actions: [
          IconButton(
            icon: Icon(Icons.sync, color: Colors.grey[700]), // Darker icon
            onPressed: () async {
              context.read<SqlBloc>().add(SyncEmailsEvent(maxResults: 10));
            },
          ),
        //   IconButton(
        //     icon: Icon(Icons.account_circle, color: Colors.grey[700]), // Darker icon
        //     onPressed: () {},
        //   ),
        ],
        centerTitle: false,
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
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                      selectedIndex = index;
                    });

                    if (tags[index] == 'All') {
                      setState(() {
                        emails = widget.emails;
                        isLoading = false;
                      });
                    } else {
                      final tagEmails = await getTagMail(tags[index]);
                      setState(() {
                        emails = tagEmails;
                        isLoading = false;
                      });
                    }
                  },
                  // onTap: () async {
                  //   setState(() {
                  //     isLoading = true;
                  //     selectedIndex = index;
                  //   });
                  //
                  //   try {
                  //     String selectedTag = tags[index];
                  //     final tagEmails = getEmailsByTag(widget.emails ,selectedTag);
                  //     setState(() {
                  //       emails = tagEmails;
                  //     });
                  //   } catch (e) {
                  //     print("Error fetching tag emails: $e");
                  //   } finally {
                  //     setState(() {
                  //       isLoading = false;
                  //     });
                  //   }
                  // },

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

          isLoading ? Center(child: CircularProgressIndicator()) : SizedBox(height: 10),

            // Emails List
            Expanded(
              child: ListView.builder(
                itemCount: emails.length,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    elevation: 0, // Remove shadow
                    margin: EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!, width: 1), // Subtle border
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50], // Lighter avatar color
                        child: Text(
                          emails[index].from[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        emails[index].subject ?? 'No Subject',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800], // Darker text
                        ),
                      ),
                      subtitle: Text(
                        name.isNotEmpty ? name : 'Unknown Sender',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]), // Darker icon
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SummarizeScreen(
                              email: emails[index],
                              emails: emails,
                            ),
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
