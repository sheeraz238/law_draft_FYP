import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';
import 'app_shell.dart';

class AuthGate extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const AuthGate({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? client.auth.currentSession;
        if (session == null) return const LoginScreen();
        return AppShell(onToggleTheme: onToggleTheme);
      },
    );
  }
}
