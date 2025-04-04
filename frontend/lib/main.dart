import 'package:atom_mail_hf/bloc/gmail_bloc.dart';
import 'package:atom_mail_hf/bloc/gmail_event.dart';
import 'package:atom_mail_hf/bloc/gmail_state.dart';
import 'package:atom_mail_hf/ui/pages/form.dart';
import 'package:atom_mail_hf/ui/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GmailBloc()..add(CheckLoginEvent()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppEntryPoint(),
      ),
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GmailBloc, GmailState>(
      builder: (context, state) {
        if (state is GmailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GmailSignedIn) {
          return SignIn(); // home
        } else {
          return SignIn();
        }
      },
    );
  }
}