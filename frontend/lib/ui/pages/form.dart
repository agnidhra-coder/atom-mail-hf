import 'package:flutter/material.dart';

class DetailsForm extends StatefulWidget {
  @override
  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otherPositionController = TextEditingController();

  final List<String> _positions = [
    'Software Engineer',
    'Designer',
    'Product Manager',
    'Data Analyst',
    'Other',
  ];

  String? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
          ),

          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value == null || !value.contains('@') ? 'Please enter a valid email' : null,
          ),

          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.length < 10 ? 'Enter valid phone number' : null,
          ),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Position'),
            items: _positions.map((position) {
              return DropdownMenuItem<String>(
                value: position,
                child: Text(position),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPosition = value;
              });
            },
            validator: (value) => value == null ? 'Please select a position' : null,
          ),

          // Show "Other Position" TextField if "Other" is selected
          if (_selectedPosition == 'Other')
            TextFormField(
              controller: _otherPositionController,
              decoration: InputDecoration(labelText: 'Enter Position'),
              validator: (value) =>
                  _selectedPosition == 'Other' && (value == null || value.isEmpty)
                      ? 'Please enter your position'
                      : null,
            ),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String position = _selectedPosition == 'Other'
                    ? _otherPositionController.text
                    : _selectedPosition ?? '';

                print("Name: ${_nameController.text}");
                print("Email: ${_emailController.text}");
                print("Phone: ${_phoneController.text}");
                print("Position: $position");

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Form submitted!')),
                );
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}