import 'package:atom_mail_hf/models/email_data.dart';
import 'package:equatable/equatable.dart';

abstract class GmailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GmailInitial extends GmailState {}

class GmailLoading extends GmailState {}

class GmailSignedIn extends GmailState {
  final String email;
  GmailSignedIn(this.email);

  @override
  List<Object?> get props => [email];
}

class GmailEmailsFetched extends GmailState {
  final List<EmailData> emails;
  GmailEmailsFetched(this.emails);

  @override
  List<Object?> get props => [emails];
}

class GmailSignedOut extends GmailState {}

class GmailError extends GmailState {
  final String message;
  GmailError(this.message);

  @override
  List<Object?> get props => [message];
}
