import 'package:atom_mail_hf/utils/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gmail_bloc.dart';
import '../bloc/gmail_event.dart';
import '../bloc/gmail_state.dart';

class SignIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GmailBloc, GmailState>(
        builder: (context, state) {
          if (state is GmailLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Text(
                      'Welcome! Smart email manager',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 200),
                CustomButton(
                  onPressed: () {
                    context.read<GmailBloc>().add(SignInEvent());
                  },
                  text: 'Sign in with Google',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
