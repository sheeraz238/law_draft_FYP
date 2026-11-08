import 'package:file_saver/file_saver.dart';
import '../models/form_schema.dart';
import 'docx_builder.dart';
import 'draft_renderer.dart';

class DocExporter {
  static Future<void> download(
    DraftSchema schema,
    Map<String, dynamic> values,
  ) async {
    final lines = DraftRenderer.render(schema, values);
    final bytes = DocxBuilder.build(lines);
    await FileSaver.instance.saveFile(
      name: '${schema.id}_draft',
      bytes: bytes,
      fileExtension: 'docx',
      mimeType: MimeType.microsoftWord,
    );
  }
}
