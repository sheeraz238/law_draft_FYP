import 'package:flutter/material.dart';
import '../models/saved_draft.dart';
import '../services/doc_exporter.dart';
import '../services/draft_codec.dart';
import '../services/draft_history_service.dart';
import '../services/schema_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = DraftHistoryService();
  List<SavedDraft> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.list();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'History load nahi hui: $e';
        _loading = false;
      });
    }
  }

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _download(SavedDraft d) async {
    final schema = SchemaService.getSchema(d.templateId);
    if (schema == null) {
      _msg('Is draft ka template ab maujood nahi');
      return;
    }
    try {
      final values = DraftCodec.decode(schema, d.formData);
      await DocExporter.download(schema, values);
      _msg('Draft downloaded');
    } catch (e) {
      _msg('Download nahi hua: $e');
    }
  }

  Future<void> _delete(SavedDraft d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete draft?'),
        content: Text(d.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.delete(d.id);
      if (!mounted) return;
      setState(() => _items.removeWhere((x) => x.id == d.id));
    } catch (e) {
      _msg('Delete nahi hua: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Drafts',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('${_items.length} generated drafts'),
              const SizedBox(height: 16),
              Expanded(
                child: _items.isEmpty
                    ? const Center(child: Text('No drafts generated yet'))
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final d = _items[i];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.description_outlined),
                              title: Text(d.title),
                              subtitle: Text(_fmt(d.createdAt)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Download again',
                                    icon: const Icon(Icons.download),
                                    onPressed: () => _download(d),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _delete(d),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
