import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_theme.dart';
import '../services/translate_service.dart';
import '../widgets/ui_kit.dart';

class TranslatorScreen extends StatefulWidget {
  final String initialText;
  const TranslatorScreen({super.key, this.initialText = ''});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  static const _langs = ['Urdu', 'Sindhi', 'English'];
  static const _max = 3000;

  late final _input = TextEditingController(text: widget.initialText);
  final _service = TranslateService();
  String _target = 'Urdu';
  String _result = '';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  bool get _rtl => _target != 'English';

  Future<void> _translate() async {
    final text = _input.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Pehle text likhein ya paste karein');
      return;
    }
    final cut = text.length > _max;
    setState(() {
      _loading = true;
      _error = cut
          ? 'Sirf pehle $_max harf ka tarjuma hoga. Baqi text alag hisse mein karein.'
          : null;
      _result = '';
    });
    try {
      final r = await _service.translate(
        cut ? text.substring(0, _max) : text,
        _target,
      );
      if (!mounted) return;
      setState(() => _result = r);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error =
            'Tarjuma nahi ho saka. Internet check karein ya thori der baad koshish karein.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Translator', style: t.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Understand a draft or guide in Urdu or Sindhi.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            Card(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'AI translation, only to help you understand. The official '
                  'draft stays in English. For Sindhi and for important text, '
                  'please ask someone who knows the language to check it.',
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
                    Row(
                      children: [
                        Text('Translate to', style: t.labelMedium),
                        const SizedBox(width: 12),
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final l in _langs)
                              ChoiceChip(
                                label: Text(l),
                                selected: _target == l,
                                onSelected: (_) => setState(() => _target = l),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _input,
                      minLines: 6,
                      maxLines: 12,
                      decoration: const InputDecoration(
                        hintText:
                            'Paste or type text here (English, Roman Urdu or any language)...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _loading ? null : _translate,
                      icon: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.canvas,
                              ),
                            )
                          : const Icon(Icons.translate, size: 18),
                      label: Text(_loading ? 'Translating...' : 'Translate'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Pill(_target.toUpperCase()),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Copy',
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _result));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Share',
                            icon: const Icon(Icons.share_outlined, size: 20),
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(text: _result),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _result,
                        textDirection: _rtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        textAlign: _rtl ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(fontSize: 18, height: 1.9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Doosri screens se kholne ke liye (apna Scaffold aur back button ke saath)
class TranslatorPage extends StatelessWidget {
  final String initialText;
  const TranslatorPage({super.key, this.initialText = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translator')),
      body: TranslatorScreen(initialText: initialText),
    );
  }
}
