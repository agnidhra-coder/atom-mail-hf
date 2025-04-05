import 'package:atom_mail_hf/bloc/bloc_gmail/gmail_bloc.dart';
import 'package:atom_mail_hf/bloc/bloc_sql/sql_bloc.dart';
import 'package:atom_mail_hf/bloc/bloc_sql/sql_event.dart';
import 'package:atom_mail_hf/test_page.dart';
import 'package:atom_mail_hf/ui/pages/form.dart';
import 'package:atom_mail_hf/ui/pages/home.dart';
import 'package:atom_mail_hf/ui/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'bloc/bloc_gmail/gmail_event.dart';
import 'bloc/bloc_gmail/gmail_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GmailBloc>(
          create: (context) => GmailBloc()..add(CheckLoginEvent()),
        ),
        BlocProvider<SqlBloc>(
          create: (context) => SqlBloc(gmailBloc: BlocProvider.of<GmailBloc>(context)),
        ),
      ],
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
        print(state);
        if (state is GmailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        } else if (state is GmailEmailsFetched) {
          return HomePage(emails: state.emails); // home
        } else if (state is GmailSignedIn) {
          context.read<SqlBloc>().add(FetchSQLDataEvent());
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        } else {
          return SignIn();
        }
      },
    );
  }
}
