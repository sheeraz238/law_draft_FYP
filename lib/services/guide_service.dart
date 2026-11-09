import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_guide.dart';

class GuideService {
  final _client = Supabase.instance.client;

  Future<List<LegalGuide>> fetchAll() async {
    final rows = await _client
        .from('legal_guides')
        .select()
        .order('topic')
        .order('title');
    return rows.map<LegalGuide>((r) => LegalGuide.fromMap(r)).toList();
  }
}
