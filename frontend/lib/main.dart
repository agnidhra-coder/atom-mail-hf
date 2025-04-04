import 'package:atom_mail_hf/bloc/gmail_bloc.dart';
import 'package:atom_mail_hf/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => GmailBloc(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Home(),
        ),);
  }

  
}
