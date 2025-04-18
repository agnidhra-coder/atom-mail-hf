import 'package:atom_mail_hf/models/email_data.dart';
import 'package:bloc/bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'gmail_event.dart';
import 'gmail_state.dart';

class GmailBloc extends Bloc<GmailEvent, GmailState> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/gmail.readonly'],
  );

  GmailBloc() : super(GmailInitial()) {
    // on<CheckLoginEvent>(_checkLogin);
    on<SignInEvent>(_signIn);
    on<FetchEmailsEvent>(_fetchEmails);
    on<SignOutEvent>(_signOut);
    on<CheckLoginEvent>(_checkLogin);
  }

  // Future<void> checkAlreadyLogin(CheckLoginEvent event, Emitter<GmailState> emit) async {
  //   emit(GmailLoading());
  //   try {
  //     final user = await googleSignIn.signInSilently();
  //     if (user != null) {
  //       emit(GmailAlreadySignedIn(user));
  //     } else {
  //       emit(GmailInitial());
  //     }
  //   } catch (e) {
  //     emit(GmailError("Failed to check login: $e"));
  //   }
  // }


  Future<void> _checkLogin(CheckLoginEvent event, Emitter<GmailState> emit) async {
    emit(GmailLoading()); // Optional: Show loading
    try {
      final user = await googleSignIn.signInSilently();
      if (user != null) {
        emit(GmailAlreadySignedIn(user));
      } else {
        emit(GmailInitial());
      }
    } catch (e) {
      emit(GmailError("Failed to check login: $e"));
    }
  }

  Future<void> _signIn(SignInEvent event, Emitter<GmailState> emit) async {
    emit(GmailLoading());
    try {
      final GoogleSignInAccount? user = await googleSignIn.signIn();
      if (user == null) {
        emit(GmailError("Sign-in aborted."));
        return;
      }
      emit(GmailSignedIn(user));
    } catch (e) {
      emit(GmailError("Sign-in failed: $e"));
    }
  }

  Future<gmail.GmailApi?> getGmailApi() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final authClient = auth.authenticatedClient(
        http.Client(),
        auth.AccessCredentials(
          auth.AccessToken('Bearer', googleAuth.accessToken!,
              DateTime.now().toUtc().add(Duration(hours: 1))),
          null,
          ['https://www.googleapis.com/auth/gmail.readonly'],
        ),
      );

      return gmail.GmailApi(authClient);
    } catch (e) {
      print("Error getting Gmail API: $e");
      return null;
    }
  }

  Future<void> _fetchEmails(FetchEmailsEvent event, Emitter<GmailState> emit) async {
    emit(GmailLoading());
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        emit(GmailError("User not signed in."));
        return;
      }

      final googleAuth = await googleUser.authentication;
      final authClient = auth.authenticatedClient(
        http.Client(),
        auth.AccessCredentials(
          auth.AccessToken('Bearer', googleAuth.accessToken!, DateTime.now().toUtc().add(Duration(hours: 1))),
          null,
          ['https://www.googleapis.com/auth/gmail.readonly'],
        ),
      );

      final gmailApi = gmail.GmailApi(authClient);
      final messagesResponse = await gmailApi.users.messages.list(
        'me',
        maxResults: 20,
        q: "-category:promotions -category:spam",
      );

      List<EmailData> emails = [];

      for (var message in messagesResponse.messages ?? []) {
        final msg = await gmailApi.users.messages.get('me', message.id!);

        final headers = msg.payload?.headers ?? [];

        String? subject = headers.firstWhere((h) => h.name == "Subject", orElse: () => gmail.MessagePartHeader(name: '', value: '')).value;
        String? from = headers.firstWhere((h) => h.name == "From", orElse: () => gmail.MessagePartHeader(name: '', value: '')).value;
        String? to = headers.firstWhere((h) => h.name == "To", orElse: () => gmail.MessagePartHeader(name: '', value: '')).value;
        String? replyTo = headers.firstWhere((h) => h.name == "Reply-To", orElse: () => gmail.MessagePartHeader(name: '', value: '')).value;
        DateTime? date;
        try {
          final dateHeader = headers.firstWhere((h) => h.name == "Date", orElse: () => gmail.MessagePartHeader(name: '', value: '')).value;
          if (dateHeader != null && dateHeader.isNotEmpty) {
            date = DateTime.tryParse(dateHeader);
          }
        } catch (_) {}

        emails.add(EmailData(
          to ?? '',
          replyTo,
          id: msg.id ?? '',
          threadId: msg.threadId ?? '',
          snippet: msg.snippet ?? '',
          subject: subject,
          from: from ?? '',
          date: date,
        ));
      }

      emit(GmailEmailsFetched(emails));
    } catch (e) {
      emit(GmailError("Failed to fetch emails: $e"));
    }
  }

  Future<void> _signOut(SignOutEvent event, Emitter<GmailState> emit) async {
    try {
      await googleSignIn.signOut();
      emit(GmailSignedOut());
    } catch (e) {
      emit(GmailError("Sign-out failed: $e"));
    }
  }
}