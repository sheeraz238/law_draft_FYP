import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/legal_guide.dart';

class ShareHelper {
  /// Phone par share sheet (WhatsApp wagera), web par WhatsApp ka link
  static Future<void> shareText(String text, {String? subject}) async {
    if (kIsWeb) {
      final t = text.length > 1800 ? '${text.substring(0, 1800)}...' : text;
      final u = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(t)}');
      await launchUrl(u, mode: LaunchMode.externalApplication);
      return;
    }
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  static String guideText(LegalGuide g, {bool footer = true}) {
    final b = StringBuffer()
      ..writeln(g.title)
      ..writeln()
      ..writeln(g.summary)
      ..writeln();
    for (var i = 0; i < g.steps.length; i++) {
      b.writeln('${i + 1}. ${g.steps[i].title}: ${g.steps[i].detail}');
    }
    if (g.documents.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Documents: ${g.documents.join(', ')}');
    }
    if (footer) {
      b
        ..writeln()
        ..writeln('Shared from Law Draft. General information only, not legal advice.');
    }
    return b.toString().trim();
  }
}