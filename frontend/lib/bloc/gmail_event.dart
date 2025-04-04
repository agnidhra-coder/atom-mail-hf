import 'package:equatable/equatable.dart';

abstract class GmailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInEvent extends GmailEvent {}

class FetchEmailsEvent extends GmailEvent {}

class SignOutEvent extends GmailEvent {}

class CheckLoginEvent extends GmailEvent {}
