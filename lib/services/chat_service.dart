import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_answer.dart';
import 'draft_service.dart';
import 'schema_service.dart';

class ChatService {
  Future<ChatAnswer> ask(
    String question, {
    List<String> guideIds = const [],
  }) async {
    // Sirf wo drafts bhejo jin ka form maujood hai
    final drafts = [
      for (final c in DraftService.getCategories())
        for (final d in c.drafts)
          if (SchemaService.getSchema(d.id) != null)
            {'id': d.id, 'title': d.title},
    ];

    final res = await Supabase.instance.client.functions
        .invoke(
          'guide-chat',
          body: {'question': question, 'drafts': drafts, 'guide_ids': guideIds},
        )
        .timeout(const Duration(seconds: 45));

    final d = res.data;
    if (d is! Map || d['answer'] == null) {
      throw Exception('Unexpected response from AI service');
    }
    return ChatAnswer(
      answer: '${d['answer']}',
      grounded: d['grounded'] == true,
      guides: ((d['guides'] as List?) ?? const [])
          .map<GuideRef>((g) => GuideRef('${g['id']}', '${g['title']}'))
          .toList(),
      draftIds: ((d['draft_ids'] as List?) ?? const [])
          .map<String>((e) => '$e')
          .toList(),
    );
  }
}
