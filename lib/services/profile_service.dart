import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  String get email => _client.auth.currentUser?.email ?? '';

  Future<UserProfile> fetch() async {
    final uid = _client.auth.currentUser!.id;
    final row = await _client.from('profiles').select().eq('id', uid).single();
    return UserProfile.fromMap(row);
  }

  Future<void> update(Map<String, dynamic> data) async {
    final uid = _client.auth.currentUser!.id;
    await _client.from('profiles').update(data).eq('id', uid);
  }

  /// Ek draft credit kaat'ta hai aur bacha hua credit wapas deta hai.
  Future<int> useDraftCredit() async {
    final res = await _client.rpc('use_draft_credit');
    return res as int;
  }
}
