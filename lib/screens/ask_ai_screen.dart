import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_answer.dart';
import '../models/legal_guide.dart';
import '../services/chat_service.dart';
import '../services/guide_service.dart';
import '../services/local_search.dart';
import '../services/schema_service.dart';
import 'draft_form_screen.dart';
import 'guide_detail_screen.dart';

class _Msg {
  final bool fromUser;
  final String text;
  final ChatAnswer? answer; // AI ka jawab
  final List<LegalGuide>? local; // null nahi to ye foran wala local nateeja hai
  final String? question; // local nateeje ke buttons ke liye
  const _Msg(
    this.fromUser,
    this.text, {
    this.answer,
    this.local,
    this.question,
  });
}

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  /// Logout par chat saaf karne ke liye
  static void clearChat() => _AskAiScreenState._msgs.clear();

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final _chat = ChatService();
  final _guideService = GuideService();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  static final List<_Msg> _msgs = [];
  List<LegalGuide> _guides = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadGuides();
    _scrollDown();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    // pehle saved copy (foran), phir internet se taaza
    final cached = await _guideService.loadCached();
    if (cached.isNotEmpty && mounted) setState(() => _guides = cached);
    try {
      final fresh = await _guideService.fetchAll();
      if (!mounted) return;
      setState(() => _guides = fresh);
    } catch (_) {}
  }

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Darja 1: foran, bina internet ke
  void _send() {
    final q = _input.text.trim();
    if (q.isEmpty) return;
    final matches = LocalSearch.rank(
      q,
      _guides,
      limit: 3,
    ).map((m) => m.guide).toList();
    setState(() {
      _msgs.add(_Msg(true, q));
      _msgs.add(_Msg(false, '', local: matches, question: q));
      _input.clear();
    });
    _scrollDown();
  }

  // Darja 2: AI (internet), sirf mili hui guides ke saath
  Future<void> _explain(String q, List<LegalGuide> local) async {
    if (_sending) return;
    setState(() => _sending = true);
    _scrollDown();
    try {
      final a = await _chat.ask(q, guideIds: [for (final g in local) g.id]);
      if (!mounted) return;
      setState(() => _msgs.add(_Msg(false, a.answer, answer: a)));
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _msgs.add(
          _Msg(
            false,
            'AI abhi masroof hai ya internet nahi hai. Saved guides upar maujood hain, ya thori der baad dobara koshish karein.\n\nDetail: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    _scrollDown();
  }

  // Darja 3: aapke apne browser mein Google search
  Future<void> _searchWeb(String q) async {
    final uri = Uri.https('www.google.com', '/search', {
      'q': '$q Pakistan law',
    });
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _msg('Browser nahi khul saka');
  }

  void _openGuide(LegalGuide g) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: g)),
    );
  }

  void _openGuideById(String id) {
    final matches = _guides.where((g) => g.id == id);
    if (matches.isNotEmpty) _openGuide(matches.first);
  }

  void _openDraft(String id) {
    final schema = SchemaService.getSchema(id);
    if (schema == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DraftFormScreen(schema: schema)),
    );
  }

  Widget _intro() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ask AI', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Type a question in English, Urdu or Roman Urdu. You first get '
              'instant results from the guides saved on this device (works '
              'offline). Then you can ask AI to explain, or search the web '
              'yourself. General information only, not legal advice. Please '
              'do not enter real names, CNIC or phone numbers, because the AI '
              'button sends your text to an AI service.',
            ),
            if (_guides.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Common questions (open instantly)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in _guides.take(6))
                    ActionChip(
                      label: Text(g.title),
                      onPressed: () => _openGuide(g),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _userBubble(_Msg m) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SelectableText(m.text),
      ),
    );
  }

  Widget _botBox(List<Widget> children) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 640),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _localBubble(_Msg m) {
    final guides = m.local!;
    final q = m.question ?? '';
    final draftIds = <String>{for (final g in guides) ...g.draftIds};
    final drafts = [
      for (final id in draftIds)
        if (SchemaService.getSchema(id) != null) SchemaService.getSchema(id)!,
    ];

    return _botBox([
      Row(
        children: [
          const Icon(Icons.bolt, size: 16),
          const SizedBox(width: 4),
          Text(
            'Instant, from saved guides',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (guides.isEmpty)
        const Text('No matching guide found in the saved data.')
      else ...[
        const Text('Closest guides:'),
        const SizedBox(height: 4),
        for (final g in guides)
          Card(
            margin: const EdgeInsets.only(top: 6),
            child: ListTile(
              dense: true,
              title: Text(g.title),
              subtitle: Text(
                '${g.topic}  •  ${g.reviewedBy == null ? 'not yet verified' : 'verified'}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openGuide(g),
            ),
          ),
      ],
      if (drafts.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Related drafts', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final s in drafts)
              ActionChip(
                avatar: const Icon(Icons.description_outlined, size: 16),
                label: Text(s.title),
                onPressed: () => _openDraft(s.id),
              ),
          ],
        ),
      ],
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.tonalIcon(
            onPressed: _sending ? null : () => _explain(q, guides),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Explain with AI'),
          ),
          OutlinedButton.icon(
            onPressed: () => _searchWeb(q),
            icon: const Icon(Icons.public, size: 18),
            label: const Text('Find on the web'),
          ),
        ],
      ),
    ]);
  }

  Widget _aiBubble(_Msg m) {
    final a = m.answer;
    final drafts = [
      for (final id in a?.draftIds ?? <String>[])
        if (SchemaService.getSchema(id) != null) SchemaService.getSchema(id)!,
    ];

    return _botBox([
      Row(
        children: [
          const Icon(Icons.auto_awesome, size: 16),
          const SizedBox(width: 4),
          Text(
            'AI explanation (needs internet)',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      const SizedBox(height: 8),
      SelectableText(m.text),
      if (a != null && !a.grounded) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'No verified guide covers this. Please consult an advocate.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
      if (a != null && a.guides.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Related guides', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final g in a.guides)
              ActionChip(
                label: Text(g.title),
                onPressed: () => _openGuideById(g.id),
              ),
          ],
        ),
      ],
      if (drafts.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Related drafts', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final s in drafts)
              ActionChip(
                avatar: const Icon(Icons.description_outlined, size: 16),
                label: Text(s.title),
                onPressed: () => _openDraft(s.id),
              ),
          ],
        ),
      ],
    ]);
  }

  Widget _bubble(_Msg m) {
    if (m.fromUser) return _userBubble(m);
    if (m.local != null) return _localBubble(m);
    return _aiBubble(m);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(24),
                children: [
                  _intro(),
                  for (final m in _msgs) _bubble(m),
                  if (_sending)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Type your question...',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
