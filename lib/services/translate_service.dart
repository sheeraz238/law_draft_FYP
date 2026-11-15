import 'package:supabase_flutter/supabase_flutter.dart';

class TranslateService {
  Future<String> translate(String text, String target) async {
    final res = await Supabase.instance.client.functions
        .invoke('translate', body: {'text': text, 'target': target})
        .timeout(const Duration(seconds: 45));
    final d = res.data;
    if (d is! Map || d['translation'] == null) {
      throw Exception('Unexpected response from translation service');
    }
    return '${d['translation']}';
  }
}
