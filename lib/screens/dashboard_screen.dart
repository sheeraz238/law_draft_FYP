import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../models/saved_draft.dart';
import '../services/draft_history_service.dart';
import '../services/updates_service.dart';
import '../widgets/ui_kit.dart';

class DashboardScreen extends StatefulWidget {
  final String name;
  final void Function(String title) onGo;
  final VoidCallback onAskAi;
  const DashboardScreen({
    super.key,
    required this.name,
    required this.onGo,
    required this.onAskAi,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<SavedDraft> _recent = [];
  List<LegalUpdate> _updates = [];
  bool _loadingRecent = true;
  bool _loadingUpdates = true;
  bool _updatesFailed = false;

  static const _sources = [
    ('Supreme Court of Pakistan', 'https://www.supremecourt.gov.pk'),
    ('Sindh High Court case law portal', 'https://caselaw.shc.gov.pk'),
    ('Pakistan Code (laws)', 'https://pakistancode.gov.pk'),
    ('FBR (tax)', 'https://www.fbr.gov.pk'),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecent();
    _loadUpdates();
  }

  Future<void> _loadRecent() async {
    try {
      final d = await DraftHistoryService().list();
      if (!mounted) return;
      setState(() {
        _recent = d.take(3).toList();
        _loadingRecent = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRecent = false);
    }
  }

  Future<void> _loadUpdates() async {
    try {
      final u = await UpdatesService().latest();
      if (!mounted) return;
      setState(() {
        _updates = u;
        _loadingUpdates = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _updatesFailed = true;
        _loadingUpdates = false;
      });
    }
  }

  Future<void> _open(String url) async {
    final u = Uri.tryParse(url);
    if (u != null) await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _tile(
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap, {
    bool primary = false,
  }) {
    return Material(
      color: primary ? AppColors.amber : AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: primary ? null : Border.all(color: AppColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: primary ? AppColors.canvas : AppColors.amber),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: primary ? AppColors.canvas : AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 12,
                  color: primary ? const Color(0xCC0B111E) : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, Widget child, {Widget? action}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _row(
    String title,
    String meta,
    VoidCallback onTap, {
    Widget? lead,
    IconData trail = Icons.chevron_right,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lead != null) ...[lead, const SizedBox(height: 6)],
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (meta.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(trail, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _recentCard() {
    Widget body;
    if (_loadingRecent) {
      body = const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else if (_recent.isEmpty) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No drafts yet. Start with a template.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => widget.onGo('Draft Library'),
            child: const Text('Open Draft Library'),
          ),
        ],
      );
    } else {
      body = Column(
        children: [
          for (final d in _recent)
            _row(d.title, _fmt(d.createdAt), () => widget.onGo('My Drafts')),
        ],
      );
    }
    return _card(
      'Recent drafts',
      body,
      action: TextButton(
        onPressed: () => widget.onGo('My Drafts'),
        child: const Text('View all'),
      ),
    );
  }

  Widget _updatesCard() {
    Widget body;
    if (_loadingUpdates) {
      body = const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else if (_updatesFailed) {
      body = const Text(
        'Updates need an internet connection.',
        style: TextStyle(color: AppColors.muted),
      );
    } else if (_updates.isEmpty) {
      body = const Text(
        'No updates yet. Headlines from official sources will appear here.',
        style: TextStyle(color: AppColors.muted),
      );
    } else {
      body = Column(
        children: [
          for (final u in _updates)
            _row(
              u.title,
              [
                if (u.source.isNotEmpty) u.source,
                if (u.date != null) _fmt(u.date!),
              ].join('  •  '),
              () => _open(u.url),
              lead: u.category.isEmpty ? null : Pill(u.category.toUpperCase()),
              trail: Icons.open_in_new,
            ),
        ],
      );
    }
    return _card('Legal updates', body);
  }

  Widget _sourcesCard() {
    return _card(
      'Official sources',
      Column(
        children: [
          for (final s in _sources)
            _row(s.$1, '', () => _open(s.$2), trail: Icons.open_in_new),
        ],
      ),
    );
  }

  Widget _disclaimer() {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'General information only, not legal advice. Please verify every '
          'draft and every update with an advocate or the official source.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: scheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final name = widget.name.trim();

    final tiles = LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 640 ? 4 : 2;
        final w = (box.maxWidth - 12 * (cols - 1)) / cols;
        Widget sized(Widget c) => SizedBox(width: w, child: c);
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            sized(
              _tile(
                Icons.edit_note_outlined,
                'New draft',
                'Start from a template',
                () => widget.onGo('Draft Library'),
                primary: true,
              ),
            ),
            sized(
              _tile(
                Icons.auto_awesome,
                'Ask AI',
                'Guides in simple words',
                widget.onAskAi,
              ),
            ),
            sized(
              _tile(
                Icons.menu_book_outlined,
                'Legal guides',
                'Step by step process',
                () => widget.onGo('Legal Guides'),
              ),
            ),
            sized(
              _tile(
                Icons.calculate_outlined,
                'Calculators',
                'Tax and inheritance',
                () => widget.onGo('Calculators'),
              ),
            ),
          ],
        );
      },
    );

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 1000;
        final left = Column(
          children: [_recentCard(), const SizedBox(height: 8), _sourcesCard()],
        );
        final right = Column(
          children: [_updatesCard(), const SizedBox(height: 8), _disclaimer()],
        );
        return SingleChildScrollView(
          padding: EdgeInsets.all(wide ? 32 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Welcome' : 'Welcome back, $name',
                    style: t.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('What do you need today?', style: t.bodySmall),
                  const SizedBox(height: 20),
                  tiles,
                  const SizedBox(height: 20),
                  wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: left),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: right),
                          ],
                        )
                      : Column(children: [left, right]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
