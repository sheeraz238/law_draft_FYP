import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../core/helplines.dart';
import '../core/rights_content.dart';
import '../services/share_helper.dart';
import '../services/speech_service.dart';
import '../widgets/ui_kit.dart';
import 'translator_screen.dart';

class RightsScreen extends StatefulWidget {
  const RightsScreen({super.key});

  @override
  State<RightsScreen> createState() => _RightsScreenState();
}

class _RightsScreenState extends State<RightsScreen> {
  int _tab = 0; // 0 = rights, 1 = helplines

  @override
  void dispose() {
    SpeechService.stop();
    super.dispose();
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _open(String url) async {
    final u = Uri.tryParse(url);
    if (u != null) await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String number) async {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    var ok = false;
    try {
      ok = await launchUrl(Uri(scheme: 'tel', path: digits));
    } catch (_) {}
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: number));
      if (mounted) _msg('Number copy ho gaya: $number');
    }
  }

  String _text(RightsCard c) {
    final b = StringBuffer()
      ..writeln('${c.title} (${c.article})')
      ..writeln();
    for (final p in c.points) {
      b.writeln('- $p');
    }
    b
      ..writeln()
      ..writeln(c.note);
    return b.toString().trim();
  }

  Widget _rightsCard(RightsCard c) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(c.article.toUpperCase()),
                const Spacer(),
                IconButton(
                  tooltip: 'Listen',
                  icon: const Icon(Icons.volume_up_outlined, size: 20),
                  onPressed: () async {
                    final err = await SpeechService.speak(_text(c));
                    if (err != null && mounted) _msg(err);
                  },
                ),
                IconButton(
                  tooltip: 'Translate',
                  icon: const Icon(Icons.translate, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TranslatorPage(initialText: _text(c)),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () => ShareHelper.shareText(
                    '${_text(c)}\n\nShared from Law Draft. General information only, not legal advice.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(c.title, style: t.titleLarge),
            const SizedBox(height: 10),
            for (final p in c.points)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.amber,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(p, style: const TextStyle(height: 1.5)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              c.note,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rightsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in rightsCards) _rightsCard(c),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _open(rightsSourceUrl),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text(
              'Read the Fundamental Rights in the Constitution',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'These cards summarise the Constitution in simple words. They are '
              'general information, not legal advice. For your own case, speak '
              'to an advocate or call a free legal helpline.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _helplineCard(Helpline h) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    h.note,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _open(h.sourceUrl),
                    child: Text(
                      'Source: ${h.source}',
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  h.number,
                  style: AppTheme.mono(
                    size: 20,
                    weight: FontWeight.w600,
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filled(
                      tooltip: 'Call',
                      icon: const Icon(Icons.call, size: 18),
                      onPressed: () => _call(h.number),
                    ),
                    IconButton(
                      tooltip: 'Copy',
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: h.number));
                        if (mounted) _msg('Copied ${h.number}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _helplinesTab() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: scheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'In immediate danger, call 15. Numbers, timings and coverage can '
              'change. Checked on $helplinesCheckedOn. Please confirm before you '
              'rely on a number.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ),
        for (final cat in helplineCategories) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
            child: Text(
              cat.toUpperCase(),
              style: AppTheme.mono(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          for (final h in helplines.where((x) => x.category == cat))
            _helplineCard(h),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Rights and Helplines', style: t.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Know your basic rights, and where to get help.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.shield_outlined),
                    label: Text('Know your rights'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.call_outlined),
                    label: Text('Helplines'),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
            ),
            const SizedBox(height: 12),
            _tab == 0 ? _rightsTab() : _helplinesTab(),
          ],
        ),
      ),
    );
  }
}
