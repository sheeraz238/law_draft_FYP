import 'package:flutter/material.dart';
import '../models/legal_guide.dart';
import '../services/guide_service.dart';
import 'guide_detail_screen.dart';
import '../services/local_search.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  final _service = GuideService();
  List<LegalGuide> _all = [];
  String _topic = 'All';
  String _query = '';
  bool _loading = true;
  bool _offline = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = await _service.loadCached();
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _all = cached;
        _loading = false;
      });
    }
    try {
      final items = await _service.fetchAll();
      if (!mounted) return;
      setState(() {
        _all = items;
        _offline = _service.usedCache;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_all.isEmpty) _error = 'Guides load nahi hue: $e';
        _loading = false;
      });
    }
  }

  List<String> get _topics => [
    'All',
    ...{for (final g in _all) g.topic}.toList()..sort(),
  ];

  List<LegalGuide> get _filtered {
    final base = _topic == 'All'
        ? _all
        : _all.where((g) => g.topic == _topic).toList();
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return base;
    final ranked = LocalSearch.rank(_query, base).map((m) => m.guide).toList();
    if (ranked.isNotEmpty) return ranked;
    // koi qareebi match na mile to purani seedhi talash
    return base
        .where(
          (g) =>
              g.title.toLowerCase().contains(q) ||
              g.summary.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    final items = _filtered;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legal Guides',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              const Text('Step by step guidance on common legal processes'),
              if (_offline)
                const Text(
                  'Offline: showing the saved copy of guides',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search guides (e.g. FIR, Khula, bail)...',

                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in _topics)
                    ChoiceChip(
                      label: Text(t),
                      selected: _topic == t,
                      onSelected: (_) => setState(() => _topic = t),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No guides found'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final g = items[i];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.route_outlined),
                              title: Text(g.title),
                              subtitle: Text('${g.topic}  •  ${g.summary}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GuideDetailScreen(guide: g),
                                ),
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
