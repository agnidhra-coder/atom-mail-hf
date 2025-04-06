// chroma_bloc.dart
import 'dart:math';
import 'package:atom_mail_hf/bloc/bloc_sql/sql_class.dart';
import 'package:atom_mail_hf/bloc/bloc_sql/sql_event.dart';
import 'package:atom_mail_hf/bloc/bloc_sql/sql_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../ui/utils/getSQLData.dart';
import '../bloc_gmail/gmail_bloc.dart';
import '../bloc_gmail/gmail_state.dart';

class SqlBloc extends Bloc<SqlEvent, SqlState> {
  final GmailBloc gmailBloc;
  final uuid = Uuid();
  String dbPath = '';
  SqlManage? _sqlManager;
  bool isInitialized = false;

  SqlBloc({required this.gmailBloc}) : super(SqlInitial()) {
    on<InitializeSqlEvent>(_initializeSql);
    on<SyncEmailsEvent>(_syncEmails);
    on<FetchSQLDataEvent>(_fetchSQLData);
    // on<QueryEmailsEvent>(_queryEmails);
  }

  Future<void> _initializeSql(
      InitializeSqlEvent event, Emitter<SqlState> emit) async {
    emit(SqlLoading());
    try {
      print('yrt block');
      await dotenv.load(fileName: ".env");

      // print("[CHROMA] Loading environment variables...");
      if (dotenv.env['GEMINI_API_KEY'] == null ||
          dotenv.env['GEMINI_API_KEY']!.isEmpty) {
        emit(SqlError("Gemini API key not found in .env file"));
        return;
      }

      _sqlManager = SqlManage();
      await _sqlManager!.initialize();
      isInitialized = true;

      final appDir = await getApplicationDocumentsDirectory();
      dbPath = '${appDir.path}/chroma_db';

      final appDirFolder = Directory(dbPath);
      if (!await appDirFolder.exists()) {
        await appDirFolder.create(recursive: true);
      }

      print('[STORAGE] Internal app storage path: $dbPath');

      final testFile = File('$dbPath/storage_test.txt');
      await testFile.writeAsString('Storage test at ${DateTime.now()}');
      print('[STORAGE] Successfully wrote test file to internal storage');

      final permission = await Permission.manageExternalStorage.request();
      if (permission.isGranted) {
        final externalDir = Directory('/storage/emulated/0/Download/AtomMail');
        if (!await externalDir.exists()) {
          await externalDir.create(recursive: true);
        }

        final externalFile = File('${externalDir.path}/embeddings_backup.txt');
        await externalFile.writeAsString(
            "Embedding data backup created at ${DateTime.now()}");
        print('[STORAGE] External backup saved to: ${externalFile.path}');
      } else {
        print(
            '[STORAGE] External storage permission denied, using internal storage only');
      }

      final pathInfoFile = File('$dbPath/storage_info.txt');
      await pathInfoFile.writeAsString('''
Storage Information:
- App internal storage: $dbPath
- Created: ${DateTime.now()}
- Email collection: gmail
''');

      emit(SqlInitialized());
    } catch (e) {
      print('[ERROR] Failed to initialize ChromaDB: $e');
      emit(SqlError("Failed to initialize ChromaDB: $e"));
    }
    print('yrt block dvds');
  }

  Future<void> _syncEmails(
      SyncEmailsEvent event, Emitter<SqlState> emit) async {
    emit(SqlLoading());
    if (!isInitialized || _sqlManager == null) {
      emit(SqlError("SQL Manager not initialized"));
      return;
    }

    try {
      final gmailState = gmailBloc.state;
      if (gmailState is! GmailSignedIn) {
        emit(SqlError("Gmail not authenticated"));
        return;
      }

      final gmailApi = await gmailBloc.getGmailApi();
      if (gmailApi == null) {
        emit(SqlError("Failed to get Gmail API"));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastSyncTime = prefs.getDouble('LAST_MAIL_TIME') ?? 0;
      final lastSyncDate =
          DateTime.fromMillisecondsSinceEpoch((lastSyncTime * 1000).toInt());

      print('[SYNC] Last sync time: ${lastSyncDate.toIso8601String()}');

      final formattedDate = DateFormat('yyyy/MM/dd').format(lastSyncDate);
      String query = 'after:$formattedDate';

      final messages = await gmailApi.users.messages.list(
        'me',
        q: query,
        maxResults: event.maxResults,
      );

      if (messages.messages == null || messages.messages!.isEmpty) {
        print('[SYNC] No new emails found');
        emit(SqlSyncComplete(0));
        return;
      }

      List<Map<String, dynamic>> emailsToAdd = [];
      int syncedCount = 0;

      for (var message in messages.messages!) {
        final fullMessage = await gmailApi.users.messages.get(
          'me',
          message.id!,
        );

        if (fullMessage.payload == null) {
          print('[SKIP] Null payload in message ${message.id}');
          continue;
        }

        String subject = '';
        String from = '';
        String to = '';
        DateTime messageTime = DateTime.now();

        for (var header in fullMessage.payload!.headers ?? []) {
          final name = header.name;
          final value = header.value ?? '';

          if (name == 'Subject') subject = value;
          if (name == 'From') from = value;
          if (name == 'To') to = value;
          if (name == 'Date') {
            final parsedDate = parseEmailDate(value);
            if (parsedDate != null) {
              messageTime = parsedDate;
            } else {
              print('[DATE] Failed to parse date: $value');
            }
          }
        }

        // for (var header in fullMessage.payload?.headers ?? []) {
        //   final name = header.name;
        //   final value = header.value ?? '';
        //
        //   if (name == 'Subject') subject = value;
        //   if (name == 'From') from = value;
        //   if (name == 'To') to = value;
        //   if (name == 'Date') {
        //     try {
        //       messageTime = DateTime.parse(value);
        //     } catch (e) {
        //       print('[DATE] Failed to parse date: $value');
        //     }
        //   }
        // }

        String body = '';
        if (fullMessage.payload!.parts != null) {
          for (var part in fullMessage.payload!.parts!) {
            if (part.mimeType == 'text/plain' && part.body?.data != null) {
              final decoded = utf8.decode(base64Url.decode(part.body!.data!));
              body += decoded;
            }
          }
        } else if (fullMessage.payload!.body?.data != null) {
          final decoded =
              utf8.decode(base64Url.decode(fullMessage.payload!.body!.data!));
          body += decoded;
        }

        final emailContent = '''
Subject: $subject
From: $from
To: $to
Date: ${messageTime.toIso8601String()}
Message ID: ${message.id}
Body:
$body
''';
        String fromId = '';
        String username = '';
        RegExp exp = RegExp(r'^(.*)<(.*)>$');
        Match? match = exp.firstMatch(from);
        if (match != null) {
          username = match.group(1)!.trim();
          fromId = match.group(2)!.trim();
        } else {
          print("Invalid format");
        }

        emailsToAdd.add({
          'content': emailContent,
          'metadata': {
            'id': message.id,
            // 'subject': subject,
            'from_email': fromId,
            'to_email': to,
            // 'date': messageTime.toIso8601String(),
            'timestamp': messageTime.millisecondsSinceEpoch / 1000,
            'thread_id': message.threadId,
          },
          // 'timestamp': messageTime.millisecondsSinceEpoch / 1000,
        });

        syncedCount++;
      }

      if (emailsToAdd.isNotEmpty) {
        await _sqlManager!.addToDatabase(emailsToAdd);
        print('[DONE] Synced $syncedCount new emails.');
        emit(SqlSyncComplete(syncedCount));
      } else {
        print('[DONE] No new emails to sync.');
        emit(SqlSyncComplete(0));
      }
    } catch (e) {
      print('[ERROR] Failed to sync emails: $e');
      emit(SqlError("Failed to sync emails: $e"));
    }
  }

  Future<void> _fetchSQLData(
      FetchSQLDataEvent event, Emitter<SqlState> emit) async {
    emit(SqlLoading()); // Emit loading state

    try {
      // Call the getSQLData function to fetch data
      final dataList = await getSQLData();

      // Check if data is fetched successfully
      if (dataList.isNotEmpty) {
        emit(SqlQueryComplete(dataList)); // Emit success state with data
      } else {
        emit(SqlError("No data found.")); // Emit error state if no data is found
      }
    } catch (e) {
      emit(SqlError("Failed to fetch data: $e")); // Emit error state on exception
    }
  }


  // Future<void> _queryEmails(
  //     QueryEmailsEvent event, Emitter<SqlState> emit) async {
  //   emit(SqlLoading());
  //   try {
  //     final appDir = await getApplicationDocumentsDirectory();
  //     final collectionDir = Directory('${appDir.path}/gmail');
  //
  //     if (!await collectionDir.exists()) {
  //       emit(SqlError("No emails have been indexed yet"));
  //       return;
  //     }
  //
  //     final files = await collectionDir
  //         .list()
  //         .where((entity) => entity is File && entity.path.endsWith('.json'))
  //         .toList();
  //
  //     List<Map<String, dynamic>> results = [];
  //
  //     for (var file in files) {
  //       if (file is File) {
  //         final content = await file.readAsString();
  //         final doc = jsonDecode(content);
  //
  //         results.add({
  //           'id': file.path.split('/').last.replaceAll('.json', ''),
  //           'content': doc['content'],
  //           'metadata': doc['metadata'],
  //           'embedding': await _calculateEmbedding(doc['content']),
  //         });
  //       }
  //     }
  //
  //     results.sort((a, b) =>
  //         (a['distance'] as double).compareTo(b['distance'] as double));
  //
  //     final topResults = results.take(event.limit).toList();
  //
  //     emit(SqlQueryComplete(topResults));
  //   } catch (e) {
  //     print('[ERROR] Failed to query emails: $e');
  //     emit(SqlError("Failed to query emails: $e"));
  //   }
  // }
  //
  // Future<List<double>> _calculateEmbedding(String text) async {
  //   try {
  //     final content = Content.text(text);
  //     final model = GenerativeModel(
  //       model: 'models/text-embedding-004',
  //       apiKey: dotenv.env['GEMINI_API_KEY']!,
  //     );
  //     final result = await model.embedContent(content);
  //     return result.embedding.values;
  //   } catch (e) {
  //     print("[ERROR] Failed to generate embedding: $e");
  //     return List.filled(512, 0.0);
  //   }
  // }

  DateTime? parseEmailDate(String dateString) {
    try {
      final formats = [
        "EEE, dd MMM yyyy HH:mm:ss Z",
        "dd MMM yyyy HH:mm:ss Z",
        "EEE, dd MMM yyyy HH:mm:ss",
        "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      ];

      for (final format in formats) {
        try {
          return DateFormat(format, 'en_US').parseUtc(dateString);
        } catch (_) {}
      }

      return DateTime.parse(dateString);
    } catch (e) {
      print('[DATE PARSER] Unrecognized format: $dateString');
      return null;
    }
  }
}
