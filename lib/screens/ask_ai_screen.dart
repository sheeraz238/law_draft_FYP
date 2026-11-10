import 'package:flutter/material.dart';
import '../models/chat_answer.dart';
import '../models/legal_guide.dart';
import '../services/chat_service.dart';
import '../services/guide_service.dart';
import '../services/schema_service.dart';
import 'draft_form_screen.dart';
import 'guide_detail_screen.dart';

class _Msg {
  final bool fromUser;
  final String text;
  final ChatAnswer? answer;
  const _Msg(this.fromUser, this.text, [this.answer]);
}

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final _chat = ChatService();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  List<LegalGuide> _guides = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    try {
      final g = await GuideService().fetchAll();
      if (!mounted) return;
      setState(() => _guides = g);
    } catch (_) {
      // chips nahi aayenge, chat phir bhi chalegi
    }
  }

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

  Future<void> _send() async {
    final q = _input.text.trim();
    if (q.isEmpty || _sending) return;
    setState(() {
      _msgs.add(_Msg(true, q));
      _sending = true;
      _input.clear();
    });
    _scrollDown();
    try {
      final a = await _chat.ask(q);
      if (!mounted) return;
      setState(() => _msgs.add(_Msg(false, a.answer, a)));
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _msgs.add(
          _Msg(
            false,
            'AI abhi masroof hai ya jawab nahi de saka. Thori der baad dobara koshish karein.\n\nDetail: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    _scrollDown();
  }

  void _openGuide(String id) {
    final matches = _guides.where((g) => g.id == id);
    if (matches.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideDetailScreen(guide: matches.first),
      ),
    );
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
              'Ask about a legal process in English, Urdu or Roman Urdu. '
              'Answers are based on the guides in this app. General '
              'information only, not legal advice. Please do not enter real '
              'names, CNIC or phone numbers, because your text is sent to an AI service.',
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
                      onPressed: () => _openGuide(g.id),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Msg m) {
    final scheme = Theme.of(context).colorScheme;
    final a = m.answer;

    if (m.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 560),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(m.text),
        ),
      );
    }

    final drafts = [
      for (final id in a?.draftIds ?? <String>[])
        if (SchemaService.getSchema(id) != null) SchemaService.getSchema(id)!,
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 640),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              Text(
                'Related guides',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final g in a.guides)
                    ActionChip(
                      label: Text(g.title),
                      onPressed: () => _openGuide(g.id),
                    ),
                ],
              ),
            ],
            if (drafts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Related drafts',
                style: Theme.of(context).textTheme.labelMedium,
              ),
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
          ],
        ),
      ),
    );
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
                    onPressed: _sending ? null : _send,
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
