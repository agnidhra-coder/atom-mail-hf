import 'package:flutter_test/flutter_test.dart';
import 'package:atom_mail_hf/models/email_data.dart';

void main() {
  group('EmailData.fromJsonWithContent - Jev fields', () {
    Map<String, dynamic> baseJson({String? category, bool? isUrgent}) => {
          'content': 'Subject: Test\nFrom: Alice <alice@example.com>\nBody: hello world',
          'metadata': {
            'thread_id': 't123',
            'tags': ['Work'],
            'category': category,
            'is_urgent': isUrgent,
          }
        };

    test('parses category and isUrgent true', () {
      final e = EmailData.fromJsonWithContent(json: baseJson(category: 'Finance', isUrgent: true), id: '1');
      expect(e.category, 'Finance');
      expect(e.isUrgent, true);
      expect(e.tags, ['Work']);
      expect(e.threadId, 't123');
    });

    test('defaults to Updates/false when null', () {
      final e = EmailData.fromJsonWithContent(json: baseJson(category: null, isUrgent: null), id: '1');
      expect(e.category, 'Updates');
      expect(e.isUrgent, false);
    });

    test('defaults when keys missing', () {
      final json = {
        'content': 'Subject: Hi\nFrom: Bob <bob@example.com>\nBody: body',
        'metadata': {'thread_id': 't2', 'tags': []}
      };
      final e = EmailData.fromJsonWithContent(json: json, id: '2');
      expect(e.category, 'Updates');
      expect(e.isUrgent, false);
    });

    test('toJson includes new fields', () {
      final e = EmailData('to@x.com', null,
          id: '1', threadId: 't1', snippet: 's', from: 'a@b.com', category: 'Spam', isUrgent: true);
      final j = e.toJson();
      expect(j['category'], 'Spam');
      expect(j['isUrgent'], true);
    });

    test('all Jev categories preserved', () {
      for (final cat in ['Work', 'Personal', 'Finance', 'Updates', 'Spam']) {
        final e = EmailData.fromJsonWithContent(json: baseJson(category: cat, isUrgent: false), id: '1');
        expect(e.category, cat);
      }
    });
  });
}
