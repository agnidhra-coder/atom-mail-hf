import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> tags = ['All', 'Work', 'Personal', 'Important', 'Starred'];
  final List<String> emails = List.generate(10, (index) => 'Email Subject ${index + 1}');
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
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(emails[index]),
                    subtitle: Text("This is a short snippet of the email..."),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
          // Add new email or compose
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
