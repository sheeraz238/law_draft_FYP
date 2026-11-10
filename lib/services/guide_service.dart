import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_guide.dart';
import 'package:flutter/foundation.dart';

class GuideService {
  final _client = Supabase.instance.client;
  static const _cacheKey = 'legal_guides_cache_v1';

  /// true agar aakhri fetchAll() internet ki jagah saved copy se aaya
  bool usedCache = false;

  Future<List<LegalGuide>> fetchAll() async {
    try {
      final rows = await _client
          .from('legal_guides')
          .select()
          .order('topic')
          .order('title')
          .timeout(const Duration(seconds: 8));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rows));
      usedCache = false;
      return rows.map<LegalGuide>((r) => LegalGuide.fromMap(r)).toList();
    } catch (e) {
      debugPrint('fetchAll failed: $e');
      final cached = await _readCache();
      if (cached != null && cached.isNotEmpty) {
        usedCache = true;
        return cached;
      }
      rethrow;
    }
  }

  /// Saved copy foran (internet ke baghair)
  Future<List<LegalGuide>> loadCached() async => (await _readCache()) ?? [];

  Future<List<LegalGuide>?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map<LegalGuide>(
            (r) => LegalGuide.fromMap(Map<String, dynamic>.from(r as Map)),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }
}
