import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/form_schema.dart';
import 'docx_builder.dart';
import 'draft_renderer.dart';

class DocExporter {
  static const _docxMime =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  static Future<void> download(
      DraftSchema schema, Map<String, dynamic> values) async {
    final lines = DraftRenderer.render(schema, values);
    final bytes = DocxBuilder.build(lines);
    final name = '${schema.id}_draft';

    if (kIsWeb) {
      // web par pehle jaisa seedha download
      await FileSaver.instance.saveFile(
        name: name,
        bytes: bytes,
        fileExtension: 'docx',
        mimeType: MimeType.microsoftWord,
      );
      return;
    }

    // Android / iOS: file bana kar share sheet kholo
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name.docx');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: _docxMime)],
        subject: schema.title,
      ),
    );
  }
}