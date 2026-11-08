import '../models/doc_line.dart';
import '../models/form_schema.dart';

class DraftRenderer {
  static List<DocLine> render(DraftSchema schema, Map<String, dynamic> v) {
    switch (schema.id) {
      case 'notice':
        return _notice(v);
      case 'khula_suit':
        return _khula(v);
      case 'pre_arrest_bail':
        return _bail(v, preArrest: true);
      case 'post_arrest_bail':
        return _bail(v, preArrest: false);
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

  // SAMPLE wording. Asli matan advocate se verify karwa kar badalna.
  static List<DocLine> _khula(Map<String, dynamic> v) {
    final first = v['first_party'] as Map<String, dynamic>;
    final second = v['second_party'] as Map<String, dynamic>;
    final marriage = _fmt(v['marriage_date'] as DateTime);
    final separation = _fmt(v['separation_date'] as DateTime);
    final children = _s(v['children']);
    var n = 0;
    String no() => '${++n}. ';

    return [
      DocLine(
        _s(v['court_name']).toUpperCase(),
        bold: true,
        align: LineAlign.center,
      ),
      DocLine.blank,
      ..._parties(first),
      DocLine('VERSUS', bold: true, align: LineAlign.center),
      ..._parties(second),
      DocLine.blank,
      DocLine(
        'SUIT FOR DISSOLUTION OF MARRIAGE ON THE BASIS OF KHULA',
        bold: true,
        underline: true,
        align: LineAlign.center,
      ),
      DocLine.blank,
      DocLine('Respectfully Sheweth:', bold: true),
      DocLine(
        '${no()}That the plaintiff was married to the defendant on $marriage '
        'at ${_s(v['marriage_place'])} according to Muslim rites. The dower '
        'was fixed at ${_s(v['dower'])}, which is '
        '${_s(v['dower_status']).toLowerCase()}.',
        align: LineAlign.justify,
      ),
      if (children.isNotEmpty)
        DocLine(
          '${no()}That the parties have the following children from the '
          'marriage: $children.',
          align: LineAlign.justify,
        ),
      DocLine(
        '${no()}That the parties have been living separately since '
        '$separation.',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That the plaintiff states the following grounds: '
        '${_s(v['grounds'])}',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That the plaintiff has developed such aversion towards the '
        'defendant that she cannot live with him as his wife within the '
        'limits prescribed by Allah.',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That this Honourable Court has jurisdiction to entertain and '
        'decide this suit.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('PRAYER', bold: true, align: LineAlign.center),
      DocLine(
        'It is, therefore, respectfully prayed that a decree for dissolution '
        'of marriage on the basis of khula may kindly be passed in favour of '
        'the plaintiff and against the defendant. Any other relief which this '
        'Honourable Court deems fit may also be granted.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('Plaintiff', bold: true, align: LineAlign.right),
      DocLine('Through Counsel', align: LineAlign.right),
    ];
  }

  // SAMPLE wording. Section numbers aur matan advocate se verify karwana.
  static List<DocLine> _bail(
    Map<String, dynamic> v, {
    required bool preArrest,
  }) {
    final first = v['first_party'] as Map<String, dynamic>;
    final firDate = _fmt(v['fir_date'] as DateTime);
    final complainant = _s(v['complainant']);
    var n = 0;
    String no() => '${++n}. ';

    final title = preArrest
        ? 'APPLICATION FOR GRANT OF PRE-ARREST BAIL UNDER SECTION 498 CR.P.C.'
        : 'APPLICATION FOR GRANT OF POST-ARREST BAIL UNDER SECTION 497 CR.P.C.';
    final custodyPara = preArrest
        ? 'That the applicant apprehends arrest in the said case and seeks '
              'the protection of this Honourable Court.'
        : 'That the applicant was arrested on '
              '${_fmt(v['arrest_date'] as DateTime)} and is presently in custody '
              'at ${_s(v['custody_place'])}.';
    final prayer = preArrest
        ? 'It is, therefore, respectfully prayed that the applicant may '
              'kindly be granted pre-arrest bail in the above-mentioned case.'
        : 'It is, therefore, respectfully prayed that the applicant may '
              'kindly be released on bail in the above-mentioned case.';

    return [
      DocLine(
        _s(v['court_name']).toUpperCase(),
        bold: true,
        align: LineAlign.center,
      ),
      DocLine.blank,
      ..._parties(first),
      DocLine('VERSUS', bold: true, align: LineAlign.center),
      DocLine('THE STATE'),
      if (complainant.isNotEmpty) DocLine('$complainant (Complainant)'),
      DocLine('...Respondent', bold: true, align: LineAlign.right),
      DocLine.blank,
      DocLine(title, bold: true, underline: true, align: LineAlign.center),
      DocLine.blank,
      DocLine('Respectfully Sheweth:', bold: true),
      DocLine(
        '${no()}That the applicant has been nominated in FIR No. '
        '${_s(v['fir_no'])} dated $firDate registered at Police Station '
        '${_s(v['police_station'])} under section(s) ${_s(v['offences'])}. '
        'The applicant denies the allegations made in the FIR.',
        align: LineAlign.justify,
      ),
      DocLine('${no()}$custodyPara', align: LineAlign.justify),
      DocLine(
        '${no()}That the grounds for bail are as follows: '
        '${_s(v['bail_grounds'])}',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That the applicant is ready to furnish bail bonds to the '
        'satisfaction of this Honourable Court.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('PRAYER', bold: true, align: LineAlign.center),
      DocLine(prayer, align: LineAlign.justify),
      DocLine.blank,
      DocLine('Applicant', bold: true, align: LineAlign.right),
      DocLine('Through Counsel', align: LineAlign.right),
    ];
  }
}
