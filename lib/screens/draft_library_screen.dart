import 'package:flutter/material.dart';
import '../models/draft_template.dart';
import '../services/draft_service.dart';
import '../services/schema_service.dart';
import 'draft_form_screen.dart';

class DraftLibraryScreen extends StatefulWidget {
  const DraftLibraryScreen({super.key});

  @override
  State<DraftLibraryScreen> createState() => _DraftLibraryScreenState();
}

class _DraftLibraryScreenState extends State<DraftLibraryScreen> {
  final _categories = DraftService.getCategories();
  String _query = '';
  String _tag = 'All';

  List<DraftCategory> get _filtered {
    final q = _query.trim().toLowerCase();
    final result = <DraftCategory>[];
    for (final c in _categories) {
      final drafts = c.drafts.where((d) {
        final tagOk = _tag == 'All' || d.tag == _tag;
        final textOk =
            q.isEmpty ||
            d.title.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q);
        return tagOk && textOk;
      }).toList();
      if (drafts.isNotEmpty) {
        result.add(DraftCategory(id: c.id, name: c.name, drafts: drafts));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cats = _filtered;
    final total = cats.fold<int>(0, (sum, c) => sum + c.drafts.length);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Drafts', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('$total drafts in ${cats.length} categories'),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search drafts (e.g. Khula, Bail, Notice)...',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final t in DraftService.tags)
                ChoiceChip(
                  label: Text(t),
                  selected: _tag == t,
                  onSelected: (_) => setState(() => _tag = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cats.isEmpty
                ? const Center(child: Text('No drafts found'))
                : _buildGrid(cats),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<DraftCategory> cats) {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 900 ? 2 : 1;
        const gap = 16.0;
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        return SingleChildScrollView(
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final c in cats)
                SizedBox(
                  width: w,
                  child: _CategoryCard(category: c),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final DraftCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final d in category.drafts)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(d.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final schema = SchemaService.getSchema(d.id);
                  if (schema == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Is draft ka form jald aayega'),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DraftFormScreen(schema: schema),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
