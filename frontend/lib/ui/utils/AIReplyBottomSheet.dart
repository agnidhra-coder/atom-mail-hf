import 'package:flutter/material.dart';

import '../../models/email_data.dart';
import 'getSQLData.dart';

class AIReplyBottomSheet extends StatefulWidget {
  final EmailData email;

  AIReplyBottomSheet(this.email);

  @override
  _AIReplyBottomSheetState createState() => _AIReplyBottomSheetState();
}

class _AIReplyBottomSheetState extends State<AIReplyBottomSheet> {
  bool isGenerating = false;
  bool isGenerated = false;
  String generatedReply = "";
  late EmailData email;

  TextEditingController promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    onPressed:
    () {
      setState(() {
        isGenerating = true;
      });
      // Simulate AI generation
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isGenerating = false;
          isGenerated = true;
          generatedReply = generatedReply;
        });
      });
    };
    style:
    ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.blue[700],
      padding: EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
    );
    return Container(
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AI Reply",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 16),

          // Prompt Input
          if (!isGenerated)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What would you like to say?",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: promptController,
                  decoration: InputDecoration(
                    hintText:
                        "E.g., Thank them for the update and ask about next steps",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                  style: TextStyle(color: Colors.grey[800]),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isGenerating
                        ? null
                        : () async {
                      if (promptController.text.trim().isEmpty) return;
                      setState(() {
                        isGenerating = true;
                        isGenerated = false;
                      });

                      try {
                        // print(email.threadId);
                        String reply = await getResponse(promptController.text, email.threadId);
                        setState(() {
                          generatedReply = reply;
                          isGenerated = true;
                        });
                      } catch (e) {
                        // Optionally show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to generate reply. Please try again."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          isGenerating = false;
                        });
                      }
                    },
                    child: isGenerating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text("Generating...",
                                  style: TextStyle(color: Colors.black)),
                            ],
                          )
                        : Text("Generate Reply",
                            style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),

          // Generated Reply Preview
          if (isGenerated)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Generated Reply",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          generatedReply,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Not satisfied? Highlight text to regenerate a specific part.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isGenerated = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[800],
                            padding: EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Regenerate"),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Show a confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Send Email"),
                                content: Text(
                                    "Are you sure you want to send this email?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel",
                                        style:
                                            TextStyle(color: Colors.grey[700])),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(
                                          context); // Close bottom sheet
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Email sent successfully!"),
                                          backgroundColor: Colors.blue[700],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue[700],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text("Send"),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue[700],
                            padding: EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Send"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
