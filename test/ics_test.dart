import 'package:flutter_test/flutter_test.dart';
import 'package:law_draft_app/services/ics_builder.dart';

void main() {
  test('builds a calendar event with a reminder', () {
    final s = IcsBuilder.build(
      title: 'Ali v. Ahmed',
      court: 'Family Court Hyderabad',
      notes: '',
      start: DateTime(2026, 12, 1, 9, 30),
      reminders: ['1 day before'],
    );
    expect(s, contains('DTSTART:20261201T093000'));
    expect(s, contains('SUMMARY:Court hearing: Ali v. Ahmed'));
    expect(s, contains('TRIGGER:-P1D'));
    expect(s, isNot(contains('DESCRIPTION:\r\n')));
  });

  test('escapes commas in the title', () {
    final s = IcsBuilder.build(
      title: 'A, B',
      court: '',
      notes: '',
      start: DateTime(2026, 12, 1, 9, 0),
      reminders: [],
    );
    expect(s, contains('SUMMARY:Court hearing: A\\, B'));
  });
}
