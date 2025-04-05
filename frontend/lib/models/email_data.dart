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

  /// Factory to parse JSON with embedded `content` string
  factory EmailData.fromJsonWithContent({
    required Map<String, dynamic> json,
    required String id,
    required String threadId,
  }) {
    final content = json['content'] as String;
    final lines = content.split('\n');

    String? subject;
    String? from;
    String? to;
    String? dateStr;
    String? replyTo;
    StringBuffer bodyBuffer = StringBuffer();

    for (var line in lines) {
      if (line.startsWith('Subject:')) {
        subject = line.replaceFirst('Subject:', '').trim();
      } else if (line.startsWith('From:')) {
        from = line.replaceFirst('From:', '').trim();
      } else if (line.startsWith('To:')) {
        to = line.replaceFirst('To:', '').trim();
      } else if (line.startsWith('Date:')) {
        dateStr = line.replaceFirst('Date:', '').trim();
      } else if (line.startsWith('Reply-To:')) {
        replyTo = line.replaceFirst('Reply-To:', '').trim();
      } else if (line.startsWith('Body:')) {
        bodyBuffer.write(line.replaceFirst('Body:', '').trim());
      } else if (bodyBuffer.isNotEmpty) {
        bodyBuffer.writeln(line);
      }
    }

    return EmailData(
      to ?? '',
      replyTo,
      id: id,
      threadId: threadId,
      snippet: bodyBuffer.toString().trim(),
      subject: subject,
      from: from ?? '',
      date: dateStr != null ? DateTime.tryParse(dateStr) : null,
    );
  }
}
