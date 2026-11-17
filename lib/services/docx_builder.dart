import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/doc_line.dart';

class DocxBuilder {
  static Uint8List build(List<DocLine> lines) {
    final archive = Archive();
    _add(archive, '[Content_Types].xml', _contentTypes);
    _add(archive, '_rels/.rels', _rels);
    _add(archive, 'word/document.xml', _document(lines));
    final data = ZipEncoder().encode(archive);
    return Uint8List.fromList(data);
  }

  static void _add(Archive archive, String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  static String _jc(LineAlign a) {
    switch (a) {
      case LineAlign.center:
        return 'center';
      case LineAlign.right:
        return 'right';
      case LineAlign.justify:
        return 'both';
      case LineAlign.left:
        return 'left';
    }
  }

  static String _paragraph(DocLine l) {
    final bold = l.bold ? '<w:b/>' : '';
    final underline = l.underline ? '<w:u w:val="single"/>' : '';
    return '<w:p>'
        '<w:pPr><w:spacing w:after="120"/><w:jc w:val="${_jc(l.align)}"/></w:pPr>'
        '<w:r><w:rPr>'
        '<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>'
        '$bold<w:sz w:val="24"/>$underline'
        '</w:rPr><w:t xml:space="preserve">${_esc(l.text)}</w:t></w:r>'
        '</w:p>';
  }

  static String _document(List<DocLine> lines) {
    final body = lines.map(_paragraph).join();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:body>$body'
        '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
        'w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
        '</w:body></w:document>';
  }

  static const _contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '</Types>';

  static const _rels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
      'Target="word/document.xml"/>'
      '</Relationships>';
}
