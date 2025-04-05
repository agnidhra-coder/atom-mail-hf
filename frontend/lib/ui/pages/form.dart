import 'package:atom_mail_hf/ui/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../bloc/bloc_gmail/gmail_bloc.dart';
import '../../bloc/bloc_gmail/gmail_event.dart';
import '../../bloc/bloc_gmail/gmail_state.dart';

class DetailsForm extends StatefulWidget {
  final String? email;
  final GoogleSignInAccount? user;

  const DetailsForm({Key? key, this.email, this.user}) : super(key: key);

  @override
  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.blue[300]!,
                Colors.blue[500]!
              ],
            ),
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _nameController,
                        hint: "Full Name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        controller: _emailController,
                        hint: "Email Address",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        controller: _phoneController,
                        hint: "Phone Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      _buildPositionDropdown(),
                      const SizedBox(height: 15),
                      if (_selectedPosition == 'Other')
                        _buildInputField(
                          controller: _otherPositionController,
                          hint: "Specify Position",
                          icon: Icons.edit,
                        ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<GmailBloc, GmailState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is GmailLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<GmailBloc>().add(FetchEmailsEvent());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.blue[700],
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: state is GmailLoading
                                  ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Continue to Dashboard',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style:  TextStyle(color: Colors.blue[900]),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.blue[300]),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hint';
        }
        return null;
      },
    );
  }

  Widget _buildPositionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPosition,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.work, color: Colors.blue[700]),
        hintText: "Select Position",
        hintStyle:  TextStyle(color: Colors.blue[300]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: _positions.map((position) {
        return DropdownMenuItem<String>(
          value: position,
          child: Text(
            position,
            style:  TextStyle(color: Colors.blue[900]),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedPosition = value),
      validator: (value) => value == null ? 'Please select position' : null,
      dropdownColor: Colors.white,
      style:  TextStyle(color: Colors.blue[900]),
      icon:  Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
    );
  }
}
