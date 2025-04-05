// chroma_state.dart
import 'package:equatable/equatable.dart';

abstract class SqlState extends Equatable {
  @override
  List get props => [];
}

class SqlInitial extends SqlState {}

class SqlLoading extends SqlState {}

class SqlInitialized extends SqlState {}

class SqlSyncComplete extends SqlState {
  final int emailsSynced;

  SqlSyncComplete(this.emailsSynced);

  @override
  List get props => [emailsSynced];
}

class SqlQueryComplete extends SqlState {
  final List<Map<String, dynamic>> results;

  SqlQueryComplete(this.results);

  @override
  List get props => [results];
}

class SqlError extends SqlState {
  final String message;

  SqlError(this.message);

  @override
  List get props => [message];
}
