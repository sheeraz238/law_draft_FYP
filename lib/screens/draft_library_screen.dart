import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/draft_template.dart';
import '../services/draft_service.dart';
import '../services/schema_service.dart';
import '../widgets/ui_kit.dart';
import 'draft_form_screen.dart';
import '../services/template_store.dart';

class _Item {
  final DraftCategory category;
  final DraftTemplate draft;
  const _Item(this.category, this.draft);
}

class DraftLibraryScreen extends StatefulWidget {
  const DraftLibraryScreen({super.key});

  @override
  State<DraftLibraryScreen> createState() => _DraftLibraryScreenState();
}

class _DraftLibraryScreenState extends State<DraftLibraryScreen> {
  final _categories = DraftService.getCategories();
  String _query = '';
  String _tag = 'All';

  bool _matches(DraftCategory c, DraftTemplate d) {
    final q = _query.trim().toLowerCase();
    final tagOk = _tag == 'All' || d.tag == _tag;
    final textOk =
        q.isEmpty ||
        d.title.toLowerCase().contains(q) ||
        c.name.toLowerCase().contains(q);
    return tagOk && textOk;
  }

  void _open(DraftTemplate d) {
    final schema = SchemaService.getSchema(d.id);
    if (schema == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Is draft ka form jald aayega')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DraftFormScreen(schema: schema)),
    );
  }

  Widget _disclaimer() {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick legal disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'These templates are starting points made from the details you '
              'enter. Please review and verify every draft with an advocate '
              'before submitting it to any court.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: scheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readyCard(_Item it) {
    final schema = SchemaService.getSchema(it.draft.id)!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(it.draft),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBox(Icons.description_outlined),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.draft.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schema.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Pill(it.draft.tag.toUpperCase()),
                        const Pill('EDITABLE DOCX', color: Color(0xFF60A5FA)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _open(it.draft),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Draft Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _soonCard(DraftCategory c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final d in c.drafts)
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _open(d),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.title,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Pill('SOON', color: AppColors.faint),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: TemplateStore.version,
      builder: (context, _, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ready = <_Item>[];
    final soon = <DraftCategory>[];
    for (final c in _categories) {
      final pending = <DraftTemplate>[];
      for (final d in c.drafts) {
        if (!_matches(c, d)) continue;
        if (SchemaService.getSchema(d.id) != null) {
          ready.add(_Item(c, d));
        } else {
          pending.add(d);
        }
      }
      if (pending.isNotEmpty) {
        soon.add(DraftCategory(id: c.id, name: c.name, drafts: pending));
      }
    }
    final soonCount = soon.fold<int>(0, (s, c) => s + c.drafts.length);
    final t = Theme.of(context).textTheme;

    final main = <Widget>[
      Text('Draft Library', style: t.headlineMedium),
      const SizedBox(height: 4),
      Text(
        '${ready.length} ready to use  •  $soonCount coming soon',
        style: t.bodySmall,
      ),
      const SizedBox(height: 20),
      TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search drafts (e.g. Khula, Bail, Notice)...',
        ),
        onChanged: (v) => setState(() => _query = v),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final tag in DraftService.tags)
            ChoiceChip(
              label: Text(tag),
              selected: _tag == tag,
              onSelected: (_) => setState(() => _tag = tag),
            ),
        ],
      ),
      const SizedBox(height: 24),
      if (ready.isEmpty && soon.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('No drafts found')),
        ),
      if (ready.isNotEmpty) ...[
        Row(
          children: [
            const Icon(Icons.star_outline, size: 20, color: AppColors.amber),
            const SizedBox(width: 8),
            Text('Ready to use', style: t.titleLarge),
          ],
        ),
        const SizedBox(height: 12),
        for (final it in ready) _readyCard(it),
      ],
      if (soon.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text('Coming soon', style: t.titleLarge),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, box) {
            final cols = box.maxWidth >= 640 ? 2 : 1;
            final w = (box.maxWidth - 16 * (cols - 1)) / cols;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final c in soon) SizedBox(width: w, child: _soonCard(c)),
              ],
            );
          },
        ),
      ],
    ];

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 1100;
        return SingleChildScrollView(
          padding: EdgeInsets.all(wide ? 32 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: main,
                          ),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(width: 320, child: _disclaimer()),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...main,
                        const SizedBox(height: 24),
                        _disclaimer(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
