import 'package:flutter/material.dart';
import '../models/case_law.dart';
import '../services/case_law_service.dart';
import '../widgets/case_law_tile.dart';

class CaseLawScreen extends StatefulWidget {
  const CaseLawScreen({super.key});

  @override
  State<CaseLawScreen> createState() => _CaseLawScreenState();
}

class _CaseLawScreenState extends State<CaseLawScreen> {
  final _service = CaseLawService();
  final _keyword = TextEditingController();
  final _year = TextEditingController();

  bool _citationTab = false;
  String _court = CaseLawService.courts.first;
  List<CaseLaw> _results = [];
  Set<String> _favs = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _keyword.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _service.search(
        keyword: _keyword.text,
        citationOnly: _citationTab,
        court: _court,
        year: int.tryParse(_year.text.trim()),
      );
      final favs = await _service.favoriteIds();
      if (!mounted) return;
      setState(() {
        _results = results;
        _favs = favs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Search nahi ho saki: $e';
        _loading = false;
      });
    }
  }

  Future<void> _toggle(CaseLaw c) async {
    final makeFav = !_favs.contains(c.id);
    try {
      await _service.setFavorite(c.id, makeFav);
      if (!mounted) return;
      setState(() {
        if (makeFav) {
          _favs.add(c.id);
        } else {
          _favs.remove(c.id);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Favorite save nahi hua: $e')));
    }
  }

  Widget _results_() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_results.isEmpty) return const Center(child: Text('No cases found'));
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final c = _results[i];
        return CaseLawTile(
          caseLaw: c,
          isFavorite: _favs.contains(c.id),
          onToggleFavorite: () => _toggle(c),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Case Law Search',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Case Law')),
                  ButtonSegment(value: true, label: Text('Citation')),
                ],
                selected: {_citationTab},
                onSelectionChanged: (s) =>
                    setState(() => _citationTab = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _keyword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: _citationTab
                      ? 'Enter citation...'
                      : 'Enter keywords, case name, or legal topic...',
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _court,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Court',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final c in CaseLawService.courts)
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (v) => setState(() => _court = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _year,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Year (e.g. 2023)',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Search Cases'),
              ),
              const SizedBox(height: 16),
              Expanded(child: _results_()),
            ],
          ),
        ),
      ),
    );
  }
}
