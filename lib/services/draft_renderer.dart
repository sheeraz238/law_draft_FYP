import '../models/doc_line.dart';
import '../models/form_schema.dart';
import 'template_renderer.dart';

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
      case 'return_surety':
        return _returnSurety(v);
      case 'eviction':
        return _eviction(v);
      case 'written_statement':
        return _writtenStatement(v);
      default:
        final doc = schema.doc;
        if (doc != null) return TemplateRenderer.render(doc, v);
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

  // Ek box ki har line ko alag point banata hai
  static List<String> _lines(String s) =>
      s.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  // SAMPLE wording. Asli matan advocate se verify karwana.
  static List<DocLine> _returnSurety(Map<String, dynamic> v) {
    final first = v['first_party'] as Map<String, dynamic>;
    final orderDate = _fmt(v['bail_order_date'] as DateTime);
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
      DocLine('THE STATE'),
      DocLine('...Respondent', bold: true, align: LineAlign.right),
      DocLine.blank,
      DocLine(
        'APPLICATION FOR RETURN OF SURETY',
        bold: true,
        underline: true,
        align: LineAlign.center,
      ),
      DocLine.blank,
      DocLine('Respectfully Sheweth:', bold: true),
      DocLine(
        '${no()}That the accused ${_s(v['accused_name'])} was granted bail by '
        'this Honourable Court on $orderDate in FIR No. ${_s(v['fir_no'])} '
        'registered at Police Station ${_s(v['police_station'])}.',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That the applicant stood surety for the accused in the '
        'amount of PKR ${_s(v['surety_amount'])} and furnished '
        '${_s(v['surety_documents'])}.',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That ${_s(v['return_reason'])}',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That the applicant now wishes to be discharged from the '
        'liability of surety.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('PRAYER', bold: true, align: LineAlign.center),
      DocLine(
        'It is, therefore, respectfully prayed that the applicant may kindly '
        'be discharged as surety and that the documents furnished as surety '
        'may be returned to the applicant.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('Applicant', bold: true, align: LineAlign.right),
      DocLine('Through Counsel', align: LineAlign.right),
    ];
  }

  // SAMPLE wording. Asli matan aur lagu hone wala qanoon advocate se verify karwana.
  static List<DocLine> _eviction(Map<String, dynamic> v) {
    final first = v['first_party'] as Map<String, dynamic>;
    final second = v['second_party'] as Map<String, dynamic>;
    final start = _fmt(v['tenancy_start'] as DateTime);
    final notice = _s(v['notice_date']);
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
        'PETITION FOR EVICTION OF TENANT',
        bold: true,
        underline: true,
        align: LineAlign.center,
      ),
      DocLine.blank,
      DocLine('Respectfully Sheweth:', bold: true),
      DocLine(
        '${no()}That the petitioner is the landlord of the premises situated '
        'at ${_s(v['premises_address'])}, which is a '
        '${_s(v['premises_type']).toLowerCase()}.',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That the respondent has been the tenant of the said premises '
        'since $start at a monthly rent of PKR ${_s(v['monthly_rent'])}.',
        align: LineAlign.justify,
      ),
      DocLine(
        '${no()}That the respondent is liable to be evicted on the following '
        'ground: ${_s(v['ground'])}. ${_s(v['ground_details'])}',
        align: LineAlign.justify,
      ),
      if (notice.isNotEmpty)
        DocLine(
          '${no()}That the petitioner served a notice on the respondent on '
          '$notice, but the respondent has not vacated the premises.',
          align: LineAlign.justify,
        ),
      DocLine(
        '${no()}That this Honourable Court has jurisdiction to hear and '
        'decide this petition.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('PRAYER', bold: true, align: LineAlign.center),
      DocLine(
        'It is, therefore, respectfully prayed that the respondent may kindly '
        'be directed to vacate the premises and hand over vacant possession '
        'to the petitioner. Any other relief which this Honourable Court '
        'deems fit may also be granted.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine('Petitioner', bold: true, align: LineAlign.right),
      DocLine('Through Counsel', align: LineAlign.right),
    ];
  }

  // SAMPLE wording. Asli matan advocate se verify karwana.
  static List<DocLine> _writtenStatement(Map<String, dynamic> v) {
    final first = v['first_party'] as Map<String, dynamic>;
    final second = v['second_party'] as Map<String, dynamic>;
    final objections = _lines(_s(v['objections']));
    final reply = _lines(_s(v['reply']));
    final extra = _lines(_s(v['additional_facts']));
    final side = _s(second['type']).toUpperCase();
    var n = 0;
    String no() => '${++n}. ';

    return [
      DocLine(
        _s(v['court_name']).toUpperCase(),
        bold: true,
        align: LineAlign.center,
      ),
      DocLine(
        'Suit No. ${_s(v['suit_no'])}',
        bold: true,
        align: LineAlign.center,
      ),
      DocLine.blank,
      ..._parties(first),
      DocLine('VERSUS', bold: true, align: LineAlign.center),
      ..._parties(second),
      DocLine.blank,
      DocLine(
        'WRITTEN STATEMENT ON BEHALF OF THE $side',
        bold: true,
        underline: true,
        align: LineAlign.center,
      ),
      DocLine('In the matter of: ${_s(v['suit_nature'])}', bold: true),
      DocLine.blank,
      DocLine('Respectfully Sheweth:', bold: true),
      if (objections.isNotEmpty) ...[
        DocLine('PRELIMINARY OBJECTIONS:', bold: true),
        for (final o in objections)
          DocLine('${no()}$o', align: LineAlign.justify),
      ],
      DocLine('REPLY ON FACTS:', bold: true),
      for (final r in reply) DocLine('${no()}$r', align: LineAlign.justify),
      if (extra.isNotEmpty) ...[
        DocLine('ADDITIONAL FACTS:', bold: true),
        for (final e in extra) DocLine('${no()}$e', align: LineAlign.justify),
      ],
      DocLine.blank,
      DocLine('PRAYER', bold: true, align: LineAlign.center),
      DocLine(
        'It is, therefore, respectfully prayed that the suit of the plaintiff '
        'may kindly be dismissed with costs.',
        align: LineAlign.justify,
      ),
      DocLine.blank,
      DocLine(_s(second['type']), bold: true, align: LineAlign.right),
      DocLine('Through Counsel', align: LineAlign.right),
    ];
  }
}
