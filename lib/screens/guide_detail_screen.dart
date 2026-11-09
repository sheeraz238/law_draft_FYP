import 'package:flutter/material.dart';
import '../models/legal_guide.dart';
import '../services/schema_service.dart';
import 'draft_form_screen.dart';

class GuideDetailScreen extends StatelessWidget {
  final LegalGuide guide;
  const GuideDetailScreen({super.key, required this.guide});

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _badge(BuildContext context) {
    final verified = guide.reviewedBy != null;
    final scheme = Theme.of(context).colorScheme;
    final text = verified
        ? 'Reviewed by ${guide.reviewedBy}'
              '${guide.reviewedOn == null ? '' : ' on ${_date(guide.reviewedOn!)}'}'
        : 'Sample content, not yet verified by an advocate';
    return Card(
      color: verified ? scheme.primaryContainer : scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(verified ? Icons.verified_outlined : Icons.warning_amber),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drafts = [
      for (final id in guide.draftIds)
        if (SchemaService.getSchema(id) != null) SchemaService.getSchema(id)!,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(guide.summary),
              const SizedBox(height: 12),
              _badge(context),
              const SizedBox(height: 8),
              Text('Steps', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (var i = 0; i < guide.steps.length; i++)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(guide.steps[i].title),
                    subtitle: Text(guide.steps[i].detail),
                  ),
                ),
              if (guide.documents.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Documents you may need',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final d in guide.documents)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(d),
                  ),
              ],
              if (drafts.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Related drafts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final s in drafts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.description_outlined),
                      label: Text('Open draft: ${s.title}'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DraftFormScreen(schema: s),
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'General information only, not legal advice. Procedures, '
                    'courts and timelines differ by case and province. Please '
                    'consult an advocate for your situation.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
