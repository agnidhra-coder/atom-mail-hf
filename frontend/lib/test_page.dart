import 'dart:math' as Math;
import 'dart:io';
import 'package:atom_mail_hf/bloc/bloc_sql/sql_state.dart';
import 'package:atom_mail_hf/ui/utils/custom_button.dart';
import 'package:atom_mail_hf/ui/utils/getSQLData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'bloc/bloc_gmail/gmail_bloc.dart';
import 'bloc/bloc_gmail/gmail_event.dart';
import 'bloc/bloc_gmail/gmail_state.dart';
import 'bloc/bloc_sql/sql_bloc.dart';
import 'bloc/bloc_sql/sql_event.dart';

class SqlGmailTest extends StatelessWidget {
  String? _appDocPath;

  SqlGmailTest() {
    _getAppDocPath();
  }

  Future<void> _getAppDocPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    _appDocPath = '${appDir.path}/gmail';
  }

  @override
  Widget build(BuildContext context) {
    final gmailBloc = BlocProvider.of<GmailBloc>(context);

    return BlocProvider<SqlBloc>(
      create: (context) =>
      SqlBloc(gmailBloc: gmailBloc)..add(InitializeSqlEvent()),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Email Embeddings Test"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPathInfoSection(),
            _buildGmailSection(context),
            SizedBox(height: 16),
            _buildChromaSection(context),
          ],
        ),
      )
    );
  }

  Widget _buildPathInfoSection() {
    return FutureBuilder<Directory>(
      future: getApplicationDocumentsDirectory(),
      builder: (context, snapshot) {
        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Storage Information",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Text("Loading path information...",
                      style: TextStyle(fontStyle: FontStyle.italic))
                else if (snapshot.hasError)
                  Text("Error getting path: ${snapshot.error}",
                      style: TextStyle(color: Colors.red))
                else if (snapshot.hasData)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("App Documents Directory:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${snapshot.data!.path}",
                            style: TextStyle(color: Colors.blue)),
                        SizedBox(height: 4),
                        Text("Email Embeddings Storage Path:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${snapshot.data!.path}/gmail",
                            style: TextStyle(color: Colors.green)),
                      ],
                    )
                  else
                    Text("Path information not available"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGmailSection(BuildContext context) {
    return BlocBuilder<GmailBloc, GmailState>(
      builder: (context, state) {
        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Gmail Status",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                if (state is GmailLoading)
                  Center(child: CircularProgressIndicator(color: Colors.blue))
                else if (state is GmailSignedIn)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("✅ Signed in as: ${state.user.email}",
                          style: TextStyle(color: Colors.green)),
                      SizedBox(height: 16),
                      CustomButton(
                        onPressed: () {
                          BlocProvider.of<GmailBloc>(context)
                              .add(FetchEmailsEvent());
                        },
                        text: 'Fetch Emails',
                      ),
                    ],
                  )
                else if (state is GmailEmailsFetched)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✅ Fetched ${state.emails.length} emails",
                            style: TextStyle(color: Colors.green)),
                        SizedBox(height: 8),
                        Text(
                            "First email subject: ${state.emails.isNotEmpty ? state.emails[0].subject ?? 'No subject' : 'No emails'}"),
                      ],
                    )
                  else if (state is GmailError)
                      Text("❌ Error: ${state.message}",
                          style: TextStyle(color: Colors.red))
                    else
                      Column(
                        children: [
                          Text("Not signed in",
                              style: TextStyle(color: Colors.orange)),
                          SizedBox(height: 16),
                          CustomButton(
                            onPressed: () {
                              BlocProvider.of<GmailBloc>(context)
                                  .add(SignInEvent());
                            },
                            text: 'Sign in with Google',
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChromaSection(BuildContext context) {
    return BlocBuilder<SqlBloc, SqlState>(
      builder: (context, state) {
        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email Embeddings Status",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                if (state is SqlLoading)
                  Center(child: CircularProgressIndicator(color: Colors.purple))
                else if (state is SqlInitialized)
                  _buildSyncAndSearchButtons(context)
                else if (state is SqlSyncComplete)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✅ Processed ${state.emailsSynced} emails",
                            style: TextStyle(color: Colors.green)),
                        SizedBox(height: 8),
                        Text("Emails stored in local device storage with embeddings",
                            style: TextStyle(fontStyle: FontStyle.italic)),
                        SizedBox(height: 16),
                        _buildSyncAndSearchButtons(context),
                      ],
                    )
                  else if (state is SqlQueryComplete)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("✅ Search results: ${state.results.length} emails found",
                              style: TextStyle(color: Colors.green)),
                          SizedBox(height: 8),
                          Container(
                            height: 200,
                            child: ListView.builder(
                              itemCount: state.results.length,
                              itemBuilder: (context, index) {
                                final result = state.results[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                result['metadata']['subject'] ??
                                                    'No subject',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              'Score: ${(1 - (result['distance'] ?? 0)).toStringAsFixed(2)}',
                                              style:
                                              TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'From: ${result['metadata']['from'] ?? 'Unknown'}',
                                          style:
                                          TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          result['content']
                                              ?.toString()
                                              .substring(
                                              0,
                                              Math.min(
                                                  100,
                                                  result['content']
                                                      ?.toString()
                                                      .length ??
                                                      0)) ??
                                              'No content',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildSyncAndSearchButtons(context),
                        ],
                      )
                    else if (state is SqlError)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("❌ Error: ${state.message}",
                                style: TextStyle(color: Colors.red)),
                            SizedBox(height: 16),
                            CustomButton(
                              onPressed: () {
                                BlocProvider.of<SqlBloc>(context)
                                    .add(InitializeSqlEvent());
                              },
                              text: 'Retry Initialization',
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Text("Email embeddings not initialized",
                                style: TextStyle(color: Colors.orange)),
                            SizedBox(height: 16),
                            CustomButton(
                              onPressed: () {
                                BlocProvider.of<SqlBloc>(context)
                                    .add(InitializeSqlEvent());
                              },
                              text: 'Initialize Embeddings',
                            ),
                          ],
                        ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncAndSearchButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onPressed: () async {
              BlocProvider.of<SqlBloc>(context)
                  .add(SyncEmailsEvent(maxResults: 25));

              // List<Map<String,dynamic>> response = await getSQLData();
              //
              // print(response[0]['content']);
            },
            text: 'Sync Emails',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: CustomButton(
            onPressed: () {
              _showQueryDialog(context);
            },
            text: 'Semantic Search',
          ),
        ),
      ],
    );
  }

  void _showQueryDialog(BuildContext context) {
    final TextEditingController _queryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Semantic Email Search"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Search emails by meaning, not just keywords. Try queries like 'meeting next week' or 'important documents'.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: "Enter search query",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_queryController.text.isNotEmpty) {
                  BlocProvider.of<SqlBloc>(context).add(
                    QueryEmailsEvent(_queryController.text, limit: 5),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text("Search"),
            ),
          ],
        );
      },
    );
  }
}
