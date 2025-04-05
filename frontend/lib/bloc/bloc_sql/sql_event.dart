// chroma_event.dart
import 'package:equatable/equatable.dart';

abstract class SqlEvent extends Equatable {
  @override
  List get props => [];
}

class InitializeSqlEvent extends SqlEvent {}

class SyncEmailsEvent extends SqlEvent {
  final int maxResults;

  SyncEmailsEvent({this.maxResults = 30});

  @override
  List get props => [maxResults];
}

class QueryEmailsEvent extends SqlEvent {
  final String queryText;
  final int limit;

  QueryEmailsEvent(this.queryText, {this.limit = 5});

  @override
  List get props => [queryText, limit];
}

class FetchSQLDataEvent extends SqlEvent {
  @override
  List<Object?> get props => [];
}

