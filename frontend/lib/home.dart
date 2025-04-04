import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gmail_bloc.dart';
import '../bloc/gmail_event.dart';
import 'bloc/gmail_state.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gmail API with BLoC"), scrolledUnderElevation: 0.0, backgroundColor: Colors.transparent,),
      body: BlocBuilder<GmailBloc, GmailState>(
        builder: (context, state) {
          if (state is GmailLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GmailSignedIn) {
            return Column(
              children: [
                Text("Signed in as: ${state.email}"),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<GmailBloc>(context).add(FetchEmailsEvent());
                  },
                  child: Text("Fetch Emails"),
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
            return Center(child: Text("Error: ${state.message}", style: TextStyle(color: Colors.red)));
          }

          return Center(
            child: ElevatedButton(
              onPressed: () {
                BlocProvider.of<GmailBloc>(context).add(SignInEvent());
              },
              child: Text("Sign in with Google"),
            ),
          );
        },
      ),
    );
  }
}
