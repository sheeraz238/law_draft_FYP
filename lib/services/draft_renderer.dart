import '../models/doc_line.dart';
import '../models/form_schema.dart';

class DraftRenderer {
  static List<DocLine> render(DraftSchema schema, Map<String, dynamic> v) {
    switch (schema.id) {
      case 'notice':
        return _notice(v);
      default:
        return [DocLine('Template not available for ${schema.title}')];
    }
  }

  static String _s(dynamic x) => (x ?? '').toString().trim();

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static List<DocLine> _parties(Map<String, dynamic> party) {
    final list = party['parties'] as List;
    final lines = <DocLine>[];
    for (var i = 0; i < list.length; i++) {
      final p = list[i] as Map<String, String>;
      final caste = (p['caste'] ?? '').trim();
      final casteText = caste.isEmpty ? '' : ', Caste $caste';
      final prefix = list.length > 1 ? '${i + 1}. ' : '';
      lines.add(
        DocLine(
          '$prefix${p['name']} ${p['relation']} ${p['father']}$casteText, R/o ${p['address']}',
          align: LineAlign.justify,
        ),
      );
    }
    lines.add(
      DocLine('...${party['type']}', bold: true, align: LineAlign.right),
    );
    return lines;
  }

  // SAMPLE wording. Asli matan advocate se verify karwa kar yahan badalna.
  static List<DocLine> _notice(Map<String, dynamic> v) {
    final first = v['first_party'] as Map<String, dynamic>;
    final second = v['second_party'] as Map<String, dynamic>;
    final date = _fmt(v['appearance_date'] as DateTime);
    final respondent = _s(second['type']);

    return [
      DocLine(
        _s(v['court_title']).toUpperCase(),
        bold: true,
        align: LineAlign.center,
      ),
      DocLine(_s(v['court_name']), bold: true, align: LineAlign.center),
      DocLine.blank,
      DocLine(_s(v['case_type']), bold: true, align: LineAlign.center),
      DocLine.blank,
      ..._parties(first),
      DocLine('VERSUS', bold: true, align: LineAlign.center),
      ..._parties(second),
      DocLine.blank,
      DocLine('NOTICE', bold: true, underline: true, align: LineAlign.center),
      DocLine.blank,
      DocLine('In the matter of: ${_s(v['suit_type'])}', bold: true),
      DocLine.blank,
      DocLine('To,'),
      DocLine('The $respondent,'),
      DocLine.blank,
      DocLine(
        'Notice is hereby given that the above-titled matter is fixed for '
        'hearing before this Honourable Court on $date. You are directed to '
        'appear in person or through counsel and to file the '
        '${_s(v['statement_type'])} on or before the said date.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('Order for: ${_s(v['order_for'])}'),
      DocLine('Date of appearance: $date'),
      DocLine.blank,
      DocLine('Presiding Officer', bold: true, align: LineAlign.right),
    ];
  }
}
