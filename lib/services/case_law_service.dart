import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/case_law.dart';

class CaseLawService {
  final _client = Supabase.instance.client;

  static const courts = [
    'All Courts',
    'Supreme Court',
    'High Court',
    'District Court',
  ];

  Future<List<CaseLaw>> search({
    String keyword = '',
    bool citationOnly = false,
    String court = 'All Courts',
    int? year,
  }) async {
    var q = _client.from('case_laws').select();

    // filter ko tordne wale special characters hata do
    final kw = keyword.replaceAll(RegExp(r'[,()%*\\]'), ' ').trim();
    if (kw.isNotEmpty) {
      if (citationOnly) {
        q = q.ilike('citation', '%$kw%');
      } else {
        q = q.or('title.ilike.%$kw%,summary.ilike.%$kw%,citation.ilike.%$kw%');
      }
    }
    if (court != 'All Courts') q = q.eq('court', court);
    if (year != null) q = q.eq('year', year);

    final rows = await q.order('year', ascending: false).limit(50);
    return rows.map<CaseLaw>((r) => CaseLaw.fromMap(r)).toList();
  }

  Future<Set<String>> favoriteIds() async {
    final rows = await _client.from('favorites').select('case_law_id');
    return rows.map<String>((r) => r['case_law_id'] as String).toSet();
  }

  Future<void> setFavorite(String caseLawId, bool favorite) async {
    if (favorite) {
      await _client.from('favorites').insert({'case_law_id': caseLawId});
    } else {
      await _client.from('favorites').delete().eq('case_law_id', caseLawId);
    }
  }

  Future<List<CaseLaw>> favorites() async {
    final rows = await _client
        .from('favorites')
        .select('case_laws(*)')
        .order('created_at', ascending: false);
    return rows
        .map<CaseLaw>(
            (r) => CaseLaw.fromMap(r['case_laws'] as Map<String, dynamic>))
        .toList();
  }
}