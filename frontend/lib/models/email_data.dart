class EmailData {
  final String id;
  final String threadId;
  final String snippet;
  final String? subject;
  final String from;
  final String to;
  final String? replyTo;
  final DateTime? date;

  EmailData(
    this.to,
    this.replyTo, {
    required this.id,
    required this.threadId,
    required this.snippet,
    this.subject,
    required this.from,
    this.date,
  });

  // Convert EmailData to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadId': threadId,
      'snippet': snippet,
      'subject': subject,
      'from': from,
      'to': to,
      'replyTo': replyTo,
      'date': date?.toIso8601String(),
    };
  }

// Create EmailData from a Map
// factory EmailData.fromJson(Map<String, dynamic> json) {
//   return EmailData(
//     json['to'],
//     json['replyTo'],
//     id: json['id'],
//     threadId: json['threadId'],
//     snippet: json['snippet'],
//     subject: json['subject'],
//     from: json['from'],
//     date: json['date'] != null ? DateTime.parse(json['date']) : null,
//   );
// }
}
