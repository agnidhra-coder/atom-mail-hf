class EmailData {
  final String id;
  final String threadId;
  final String snippet;
  final String? subject;
  final String? from;
  final String? to;
  final String? replyTo;
  final DateTime? date;

  EmailData(
    this.to,
    this.replyTo, {
    required this.id,
    required this.threadId,
    required this.snippet,
    this.subject,
    this.from,
    this.date,
  });
}
