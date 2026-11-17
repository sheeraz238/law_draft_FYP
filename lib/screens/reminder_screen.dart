import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ics_builder.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _title = TextEditingController();
  final _court = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _date;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  final Set<String> _reminders = {'1 day before'};

  @override
  void dispose() {
    _title.dispose();
    _court.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  DateTime? _start() {
    if (_title.text.trim().isEmpty) {
      _msg('Case ka naam likhein');
      return null;
    }
    if (_date == null) {
      _msg('Hearing ki tareekh chunein');
      return null;
    }
    return DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time.hour,
      _time.minute,
    );
  }

  Future<void> _google() async {
    final s = _start();
    if (s == null) return;
    final ok = await launchUrl(
      IcsBuilder.googleCalendarUri(
        title: _title.text.trim(),
        court: _court.text.trim(),
        notes: _notes.text.trim(),
        start: s,
      ),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) _msg('Calendar nahi khul saka');
  }

  Future<void> _ics() async {
    final s = _start();
    if (s == null) return;
    final text = IcsBuilder.build(
      title: _title.text.trim(),
      court: _court.text.trim(),
      notes: _notes.text.trim(),
      start: s,
      reminders: _reminders.toList(),
    );
    final bytes = Uint8List.fromList(utf8.encode(text));
    try {
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'hearing',
          bytes: bytes,
          fileExtension: 'ics',
          mimeType: MimeType.text,
        );
      } else {
        final dir = await getTemporaryDirectory();
        final f = File('${dir.path}/hearing.ics');
        await f.writeAsBytes(bytes, flush: true);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(f.path, mimeType: 'text/calendar')],
            subject: 'Court hearing reminder',
          ),
        );
      }
    } catch (_) {
      if (mounted) _msg('File nahi ban saki');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Hearing Reminder', style: t.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Save your hearing date in your phone calendar.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            Card(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'This is only a reminder for you. Always confirm the hearing '
                  'date and time from the court or the cause list.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Case name *',
                        hintText: 'e.g. Ali versus Ahmed',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _court,
                      decoration: const InputDecoration(
                        labelText: 'Court',
                        hintText: 'e.g. Family Court Hyderabad',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              _date == null ? 'Choose date' : _fmtDate(_date!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(_time.format(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notes,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'e.g. bring the original Nikahnama',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Remind me (used by the calendar file)',
                      style: t.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in IcsBuilder.triggers.keys)
                          FilterChip(
                            label: Text(r),
                            selected: _reminders.contains(r),
                            showCheckmark: false,
                            onSelected: (v) => setState(() {
                              if (v) {
                                _reminders.add(r);
                              } else {
                                _reminders.remove(r);
                              }
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _google,
                      icon: const Icon(Icons.event_available, size: 18),
                      label: const Text('Add to Google Calendar'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _ics,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Calendar file (.ics) with reminders'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
