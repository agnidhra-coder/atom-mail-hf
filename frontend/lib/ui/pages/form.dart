import 'package:atom_mail_hf/ui/pages/home.dart';
import 'package:atom_mail_hf/ui/utils/custom_button.dart';
import 'package:atom_mail_hf/ui/utils/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/monitoring/v3.dart';

import '../../bloc/bloc_gmail/gmail_bloc.dart';
import '../../bloc/bloc_gmail/gmail_event.dart';
import '../../bloc/bloc_gmail/gmail_state.dart';

class DetailsForm extends StatefulWidget {
  final String? email;
  final GoogleSignInAccount? user;

  const DetailsForm({super.key, this.email, this.user});
  @override
  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print("Email: ${widget.email}");
    
    _nameController.text = widget.user?.displayName ?? '';
    _emailController.text = widget.user?.email ?? '';
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Form'),
        centerTitle: true,
      ),
      body: BlocListener<GmailBloc, GmailState>(
        listener: (context, state) {
          if (state is GmailEmailsFetched) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(emails: state.emails),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomInputField(
                  isEnabled: true,
                  controller: _nameController,
                  hintText: "Name",
                  icon: Icons.person,
                ),
                SizedBox(height: 10),
                CustomInputField(
                  isEnabled: true,
                  controller: _emailController,
                  hintText: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                CustomInputField(
                  controller: _phoneController,
                  hintText: "Phone",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedPosition,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.work, color: Colors.black54),
                    hintText: "Position",
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
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
                  validator: (value) =>
                  value == null ? 'Please select a position' : null,
                ),
                SizedBox(height: 10),
                if (_selectedPosition == 'Other')
                  CustomInputField(
                    controller: _otherPositionController,
                    hintText: "Other Position",
                    icon: null,
                  ),
                SizedBox(height: 10),
                BlocBuilder<GmailBloc, GmailState>(
                  builder: (context, state) {
                    if (state is GmailLoading) {
                      return Center(child: CircularProgressIndicator(color: Colors.black));
                    }

                    return CustomButton(
                      text: "Submit",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<GmailBloc>().add(FetchEmailsEvent());
                        }
                      },
                    );
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

}