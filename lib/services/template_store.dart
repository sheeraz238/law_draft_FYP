import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/draft_template.dart';
import '../models/form_schema.dart';

/// Supabase ke draft cards (saved copy ke saath)
class TemplateStore {
  static const _cacheKey = 'draft_templates_cache_v1';
  static final ValueNotifier<int> version = ValueNotifier<int>(0);
  static List<Map<String, dynamic>> _rows = [];
  static Map<String, DraftSchema> _schemas = {};

  static DraftSchema? schemaFor(String id) => _schemas[id];

  static Future<void> loadCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      _apply(list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
    } catch (_) {}
  }

  static Future<void> refresh() async {
    try {
      final rows = await Supabase.instance.client
          .from('draft_templates')
          .select()
          .eq('published', true)
          .order('sort')
          .timeout(const Duration(seconds: 8));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rows));
      _apply(List<Map<String, dynamic>>.from(rows));
    } catch (_) {
      // internet na ho to saved copy chalti rahegi
    }
  }

  static void _apply(List<Map<String, dynamic>> rows) {
    final schemas = <String, DraftSchema>{};
    final good = <Map<String, dynamic>>[];
    for (final r in rows) {
      try {
        schemas['${r['id']}'] = _toSchema(r);
        good.add(r);
      } catch (_) {
        // kharab card ko chhod do, baqi chalte rahein
      }
    }
    _rows = good;
    _schemas = schemas;
    version.value++;
  }

  static FieldType _type(String s) {
    switch (s) {
      case 'multiline':
        return FieldType.multiline;
      case 'dropdown':
        return FieldType.dropdown;
      case 'date':
        return FieldType.date;
      case 'parties':
        return FieldType.parties;
      default:
        return FieldType.text;
    }
  }

  static DraftSchema _toSchema(Map<String, dynamic> r) {
    final sections = <FormSectionDef>[];
    for (final s in (r['form'] as List)) {
      final fields = <FormFieldDef>[];
      for (final f in (s['fields'] as List)) {
        final type = _type('${f['type'] ?? 'text'}');
        final options =
            ((f['options'] as List?) ?? const []).map((e) => '$e').toList();
        if ((type == FieldType.dropdown || type == FieldType.parties) &&
            options.isEmpty) {
          throw Exception('options needed');
        }
        fields.add(FormFieldDef(
          key: '${f['key']}',
          label: '${f['label']}',
          type: type,
          required: f['required'] != false,
          hint: f['hint'] as String?,
          options: options,
          typeLabel: f['typeLabel'] as String?,
        ));
      }
      sections.add(FormSectionDef(title: '${s['title']}', fields: fields));
    }
    return DraftSchema(
      id: '${r['id']}',
      title: '${r['title']}',
      description: '${r['description'] ?? ''}',
      sections: sections,
      doc: List<dynamic>.from(r['document'] as List),
    );
  }

  /// Library ki categories mein Supabase ke drafts mila deta hai
  static List<DraftCategory> merge(List<DraftCategory> base) {
    if (_rows.isEmpty) return base;
    final names = <String>[];
    final ids = <String, String>{};
    final map = <String, List<DraftTemplate>>{};
    for (final c in base) {
      names.add(c.name);
      ids[c.name] = c.id;
      map[c.name] = [...c.drafts];
    }
    for (final r in _rows) {
      final id = '${r['id']}';
      for (final l in map.values) {
        l.removeWhere((d) => d.id == id);
      }
      final cat = '${r['category'] ?? 'Other'}';
      final list = map.putIfAbsent(cat, () {
        names.add(cat);
        ids[cat] = cat.toLowerCase().replaceAll(' ', '_');
        return <DraftTemplate>[];
      });
      list.add(DraftTemplate(
        id: id,
        title: '${r['title']}',
        tag: '${r['tag'] ?? ''}',
      ));
    }
    return [
      for (final n in names)
        if (map[n]!.isNotEmpty)
          DraftCategory(id: ids[n]!, name: n, drafts: map[n]!),
    ];
  }
}