import '../models/form_schema.dart';

/// Form ke values ko JSON mein badalta hai aur wapas wahi types bahal karta hai.
class DraftCodec {
  static Map<String, dynamic> encode(
    DraftSchema schema,
    Map<String, dynamic> values,
  ) {
    final out = <String, dynamic>{};
    for (final s in schema.sections) {
      for (final f in s.fields) {
        final v = values[f.key];
        out[f.key] = (f.type == FieldType.date && v is DateTime)
            ? v.toIso8601String()
            : v;
      }
    }
    return out;
  }

  static Map<String, dynamic> decode(
    DraftSchema schema,
    Map<String, dynamic> json,
  ) {
    final out = <String, dynamic>{};
    for (final s in schema.sections) {
      for (final f in s.fields) {
        final v = json[f.key];
        switch (f.type) {
          case FieldType.date:
            out[f.key] = DateTime.tryParse('${v ?? ''}') ?? DateTime.now();
            break;
          case FieldType.parties:
            final m = (v is Map) ? v : const {};
            final list = ((m['parties'] as List?) ?? const [])
                .map<Map<String, String>>(
                  (p) => (p as Map).map(
                    (k, val) => MapEntry('$k', '${val ?? ''}'),
                  ),
                )
                .toList();
            out[f.key] = {
              'type': '${m['type'] ?? f.options.first}',
              'parties': list,
            };
            break;
          default:
            out[f.key] = '${v ?? ''}';
        }
      }
    }
    return out;
  }
}
