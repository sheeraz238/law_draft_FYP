import 'package:flutter/material.dart';
import '../models/ai_suggestion.dart';
import '../services/ai_service.dart';
import '../services/schema_service.dart';
import 'draft_form_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _service = AiService();
  final _text = TextEditingController();
  List<AiSuggestion>? _results;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final q = _text.text.trim();
    if (q.isEmpty) {
      setState(() => _error = 'Pehle apna masla likhein');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _results = null;
    });
    try {
      final r = await _service.suggestDrafts(q);
      if (!mounted) return;
      setState(() => _results = r);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _error =
            'AI abhi masroof hai ya jawab nahi de saka. Thori der baad dobara koshish karein.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(AiSuggestion s) {
    final schema = SchemaService.getSchema(s.id);
    if (schema == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DraftFormScreen(schema: schema)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'AI Draft Assistant',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Apna masla English, Urdu ya Roman Urdu mein likhein. AI sahi draft '
              'suggest karega. Ye sirf rehnumai hai, qanooni mashwara nahi.',
            ),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Privacy: asli naam, CNIC, pata ya phone number mat likhein. '
                  'Ye text AI service ko bheja jata hai.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'e.g. Mujhe apne shauhar se khula chahiye',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _loading ? null : _ask,
              icon: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Soch raha hai...' : 'Suggest drafts'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            if (_results != null && _results!.isEmpty)
              const Text(
                'Koi munasib draft nahi mila. Masla thora tafseel se likhein.',
              ),
            for (final s in _results ?? <AiSuggestion>[])
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(s.title),
                  subtitle: Text(s.reason),
                  trailing: TextButton(
                    onPressed: () => _open(s),
                    child: const Text('Open form'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
