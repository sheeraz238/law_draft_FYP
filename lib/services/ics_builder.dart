/// Calendar ki event file (.ics) aur Google Calendar ka link banata hai
class IcsBuilder {
  static const triggers = {
    '1 week before': '-P7D',
    '1 day before': '-P1D',
    '2 hours before': '-PT2H',
  };

  static String _esc(String s) => s
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll('\n', '\\n');

  static String _p(int n) => n.toString().padLeft(2, '0');

  static String _local(DateTime d) =>
      '${d.year}${_p(d.month)}${_p(d.day)}T${_p(d.hour)}${_p(d.minute)}00';

  static String _utc(DateTime d) {
    final u = d.toUtc();
    return '${u.year}${_p(u.month)}${_p(u.day)}T${_p(u.hour)}${_p(u.minute)}${_p(u.second)}Z';
  }

  static String build({
    required String title,
    required String court,
    required String notes,
    required DateTime start,
    required List<String> reminders,
  }) {
    final end = start.add(const Duration(hours: 1));
    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Law Draft//Hearing Reminder//EN',
      'BEGIN:VEVENT',
      'UID:${DateTime.now().microsecondsSinceEpoch}@lawdraft',
      'DTSTAMP:${_utc(DateTime.now())}',
      'DTSTART:${_local(start)}',
      'DTEND:${_local(end)}',
      'SUMMARY:${_esc('Court hearing: $title')}',
      if (court.isNotEmpty) 'LOCATION:${_esc(court)}',
      if (notes.isNotEmpty) 'DESCRIPTION:${_esc(notes)}',
      for (final r in reminders)
        if (triggers.containsKey(r)) ...[
          'BEGIN:VALARM',
          'TRIGGER:${triggers[r]}',
          'ACTION:DISPLAY',
          'DESCRIPTION:Hearing reminder',
          'END:VALARM',
        ],
      'END:VEVENT',
      'END:VCALENDAR',
    ];
    return '${lines.join('\r\n')}\r\n';
  }

  static Uri googleCalendarUri({
    required String title,
    required String court,
    required String notes,
    required DateTime start,
  }) {
    final end = start.add(const Duration(hours: 1));
    String q(String s) => Uri.encodeQueryComponent(s);
    return Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${q('Court hearing: $title')}'
      '&dates=${_local(start)}/${_local(end)}'
      '&details=${q(notes)}'
      '&location=${q(court)}',
    );
  }
}
