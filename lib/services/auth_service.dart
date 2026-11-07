import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _auth = Supabase.instance.client.auth;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithPassword(email: email, password: password);

  Future<void> signUp(String email, String password, String fullName) => _auth
      .signUp(email: email, password: password, data: {'full_name': fullName});

  Future<void> signOut() => _auth.signOut();
}
