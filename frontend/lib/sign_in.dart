import 'package:atom_mail_hf/ui/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gmail_bloc.dart';
import '../bloc/gmail_event.dart';
import 'bloc/gmail_state.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Atom Mail"),
      //   scrolledUnderElevation: 0.0,
      //   backgroundColor: Colors.transparent,
      // ),
      body: BlocBuilder<GmailBloc, GmailState>(
        builder: (context, state) {
          if (state is GmailLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          } else if (state is GmailSignedIn) {
            return Column(
              children: [
                Text("Signed in as: ${state.email}"),
                CustomButton(
                  onPressed: () {
                    BlocProvider.of<GmailBloc>(context).add(FetchEmailsEvent());
                  },
                  text: 'Fetch Emails',
                ),
              ],
            );
          } else if (state is GmailEmailsFetched) {
            return ListView.builder(
              itemCount: state.emails.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(state.emails[index]));
              },
            );
          } else if (state is GmailError) {
            return Center(
                child: Text("Error: ${state.message}",
                    style: TextStyle(color: Colors.red)));
          }

          // when signed out
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child:Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child:  Text(
                    'Welcome! Smart email manager',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),)
                ),
                SizedBox(height: 200,),
                CustomButton(
                  onPressed: () {
                    BlocProvider.of<GmailBloc>(context).add(SignInEvent());
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