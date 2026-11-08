import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/form_schema.dart';
import '../models/saved_draft.dart';
import 'draft_codec.dart';

class DraftHistoryService {
  final _client = Supabase.instance.client;

  Future<void> save(DraftSchema schema, Map<String, dynamic> values) async {
    await _client.from('generated_drafts').insert({
      'template_id': schema.id,
      'title': schema.title,
      'form_data': DraftCodec.encode(schema, values),
    });
  }

  Future<List<SavedDraft>> list() async {
    final rows = await _client
        .from('generated_drafts')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map<SavedDraft>((r) => SavedDraft.fromMap(r)).toList();
  }

  Future<void> delete(String id) async {
    await _client.from('generated_drafts').delete().eq('id', id);
  }
}
