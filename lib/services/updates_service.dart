import 'package:supabase_flutter/supabase_flutter.dart';

class LegalUpdate {
  final String title;
  final String source;
  final String category;
  final String url;
  final DateTime? date;
  const LegalUpdate({
    required this.title,
    required this.source,
    required this.category,
    required this.url,
    required this.date,
  });
}

class UpdatesService {
  Future<List<LegalUpdate>> latest() async {
    final rows = await Supabase.instance.client
        .from('legal_updates')
        .select()
        .order('published_on', ascending: false)
        .limit(5)
        .timeout(const Duration(seconds: 8));
    return rows
        .map<LegalUpdate>(
          (r) => LegalUpdate(
            title: (r['title'] ?? '') as String,
            source: (r['source'] ?? '') as String,
            category: (r['category'] ?? '') as String,
            url: (r['url'] ?? '') as String,
            date: r['published_on'] == null
                ? null
                : DateTime.tryParse('${r['published_on']}'),
          ),
        )
        .toList();
  }
}
