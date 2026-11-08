import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_suggestion.dart';
import 'draft_service.dart';
import 'schema_service.dart';

class AiService {
  Future<List<AiSuggestion>> suggestDrafts(String description) async {
    // Sirf wo drafts bhejo jin ka form maujood hai
    final drafts = [
      for (final c in DraftService.getCategories())
        for (final d in c.drafts)
          if (SchemaService.getSchema(d.id) != null)
            {'id': d.id, 'title': d.title},
    ];

    final res = await Supabase.instance.client.functions.invoke(
      'suggest-draft',
      body: {'description': description, 'drafts': drafts},
    );

    final data = res.data;
    if (data is! Map || data['suggestions'] is! List) {
      throw Exception('Unexpected response from AI service');
    }
    return (data['suggestions'] as List)
        .map<AiSuggestion>(
          (s) => AiSuggestion(
            id: '${s['id']}',
            title: '${s['title']}',
            reason: '${s['reason'] ?? ''}',
          ),
        )
        .toList();
  }
}
