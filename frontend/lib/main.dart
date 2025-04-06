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
import 'bloc/bloc_sql/sql_state.dart';
import 'models/email_data.dart';

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
        BlocProvider(
          create: (context) {
            print('[DEBUG] MyApp: Creating GmailBloc');
            return GmailBloc()..add(CheckLoginEvent());
          },
        ),
        BlocProvider(
            // create: (context) => SqlBloc(gmailBloc: BlocProvider.of<GmailBloc>(context))
            create: (context) {
          final gmailBloc = BlocProvider.of<GmailBloc>(context);
          print('[DEBUG] MyApp: Creating SqlBloc with GmailBloc');
          return SqlBloc(gmailBloc: gmailBloc)..add(InitializeSqlEvent());
        })
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SqlGmailTest(),
        // home: SqlGmailTest(),
      ),
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GmailBloc, GmailState>(
          listener: (context, state) {
            if (state is GmailAlreadySignedIn) {
              context.read<SqlBloc>().add(FetchSQLDataEvent());
            } else if (state is GmailSignedIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailsForm(user: state.user)),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<GmailBloc, GmailState>(
        builder: (context, gmailState) {
          if (gmailState is GmailLoading) {
            return const Scaffold(
              body:
                  Center(child: CircularProgressIndicator(color: Colors.black)),
            );
          } else if (gmailState is GmailEmailsFetched) {
            return HomePage(emails: gmailState.emails);
          } else if (gmailState is GmailAlreadySignedIn) {
            return BlocBuilder<SqlBloc, SqlState>(
              builder: (context, sqlState) {
                if (sqlState is SqlLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (sqlState is SqlQueryComplete) {
                  List<EmailData> emails = [];

                  for (var item in sqlState.results) {
                    final email = EmailData.fromJsonWithContent(
                      json: item,
                      id: 'null',
                    );

                    emails.add(email);
                  }
                  return HomePage(emails: emails);
                } else {
                  return const Scaffold(
                    body: Center(child: Text("Fetching cached emails...")),
                  );
                }
              },
            );
          } else {
            return SignIn();
          }
        },
      ),
    );
  }
}
