import 'package:flutter/material.dart';
import '../models/case_law.dart';
import '../services/case_law_service.dart';
import '../widgets/case_law_tile.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = CaseLawService();
  List<CaseLaw> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.favorites();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Favorites load nahi hue: $e';
        _loading = false;
      });
    }
  }

  Future<void> _remove(CaseLaw c) async {
    try {
      await _service.setFavorite(c.id, false);
      if (!mounted) return;
      setState(() => _items.removeWhere((x) => x.id == c.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Remove nahi hua: $e')));
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
                'Favorite Cases',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('${_items.length} saved cases'),
              const SizedBox(height: 16),
              Expanded(
                child: _items.isEmpty
                    ? const Center(
                        child: Text(
                          'No favorite cases yet. Tap the heart on a case to save it.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final c = _items[i];
                          return CaseLawTile(
                            caseLaw: c,
                            isFavorite: true,
                            onToggleFavorite: () => _remove(c),
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
