import '../models/doc_line.dart';

/// Draft card ke "document" hisse se text banata hai
class TemplateRenderer {
  static final _ph =
      RegExp(r'\{(\w+)(?:\.(type|name))?(?:\|(upper|lower))?\}');

  static List<DocLine> render(List<dynamic> spec, Map<String, dynamic> v) {
    final out = <DocLine>[];
    var n = 0;
    for (final raw in spec) {
      if (raw is! Map) continue;
      final s = Map<String, dynamic>.from(raw);
      if (s['blank'] == true) {
        out.add(DocLine.blank);
        continue;
      }
      if (!_cond(s['if'], v)) continue;

      final p = s['parties'];
      if (p is String) {
        out.addAll(_parties(v[p]));
        continue;
      }
      final each = s['each'];
      if (each is String) {
        for (final item in _lines('${v[each] ?? ''}')) {
          out.add(_line(s, v, item: item, num: s['n'] == true ? ++n : null));
        }
        continue;
      }
      out.add(_line(s, v, num: s['n'] == true ? ++n : null));
    }
    return out;
  }

  static DocLine _line(Map<String, dynamic> s, Map<String, dynamic> v,
      {String? item, int? num}) {
    final text = _fill('${s['t'] ?? ''}', v, item);
    return DocLine(
      num == null ? text : '$num. $text',
      bold: s['b'] == true,
      underline: s['u'] == true,
      align: _align('${s['a'] ?? 'l'}'),
    );
  }

  static LineAlign _align(String a) {
    switch (a) {
      case 'c':
        return LineAlign.center;
      case 'r':
        return LineAlign.right;
      case 'j':
        return LineAlign.justify;
      default:
        return LineAlign.left;
    }
  }

  static String _fill(String t, Map<String, dynamic> v, String? item) {
    return t.replaceAllMapped(_ph, (m) {
      final key = m[1]!;
      var val = key == 'item' ? (item ?? '') : _value(v[key], m[2]);
      if (m[3] == 'upper') val = val.toUpperCase();
      if (m[3] == 'lower') val = val.toLowerCase();
      return val;
    });
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _value(dynamic x, String? part) {
    if (x == null) return '';
    if (x is DateTime) return _fmt(x);
    if (x is Map) {
      if (part == 'type') return '${x['type'] ?? ''}';
      if (part == 'name') {
        final l = x['parties'] as List?;
        if (l != null && l.isNotEmpty) return '${(l.first as Map)['name'] ?? ''}';
      }
      return '';
    }
    return '$x'.trim();
  }

  static bool _cond(dynamic c, Map<String, dynamic> v) {
    if (c is! String) return true;
    if (c.contains('=')) {
      final i = c.indexOf('=');
      return _value(v[c.substring(0, i)], null) == c.substring(i + 1);
    }
    return _value(v[c], null).isNotEmpty;
  }

  static List<String> _lines(String s) => s
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  static List<DocLine> _parties(dynamic party) {
    if (party is! Map) return [];
    final list = (party['parties'] as List?) ?? const [];
    final lines = <DocLine>[];
    for (var i = 0; i < list.length; i++) {
      final p = list[i] as Map;
      final caste = '${p['caste'] ?? ''}'.trim();
      final casteText = caste.isEmpty ? '' : ', Caste $caste';
      final prefix = list.length > 1 ? '${i + 1}. ' : '';
      lines.add(DocLine(
        '$prefix${p['name']} ${p['relation']} ${p['father']}$casteText, R/o ${p['address']}',
        align: LineAlign.justify,
      ));
    }
    lines.add(DocLine('...${party['type']}',
        bold: true, align: LineAlign.right));
    return lines;
  }
}