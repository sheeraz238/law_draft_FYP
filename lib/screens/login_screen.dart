import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_info.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/ui_kit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        await _auth.signUp(
          _email.text.trim(),
          _password.text,
          _name.text.trim(),
        );
      } else {
        await _auth.signIn(_email.text.trim(), _password.text);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _brand() {
    return Row(
      children: [
        const IconBox(Icons.balance, size: 44),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppInfo.appName.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Pill('PAKISTAN', color: AppColors.amber),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              AppInfo.tagline,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _feature(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Pill('LEGAL DRAFTING FOR PAKISTAN', color: AppColors.amber),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: t.displayMedium,
            children: [
              const TextSpan(text: 'Your legal drafting workspace for '),
              TextSpan(
                text: 'Pakistan',
                style: t.displayMedium?.copyWith(color: AppColors.amber),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Generate court drafts from guided forms, follow step by step legal '
          'guides, and use inheritance and property tax calculators.',
          style: t.bodyLarge?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 28),
        _feature(
          Icons.description_outlined,
          'Guided drafts',
          'Fill a form and download an editable DOCX file.',
        ),
        _feature(
          Icons.menu_book_outlined,
          'Legal guides',
          'Step by step processes you can read even without internet.',
        ),
        _feature(
          Icons.calculate_outlined,
          'Calculators',
          'Islamic inheritance shares and property advance tax.',
        ),
      ],
    );
  }

  Widget _card() {
    final t = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sidebar,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 3, color: AppColors.amber),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: IconBox(Icons.shield_outlined, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSignUp
                            ? 'Create your account'
                            : 'Sign in to your account',
                        textAlign: TextAlign.center,
                        style: t.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isSignUp
                            ? 'It takes a minute. No card needed.'
                            : 'Enter your email and password to continue.',
                        textAlign: TextAlign.center,
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'At least 6 characters'
                            : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ],
                      const SizedBox(height: 22),
                      GoldButton(
                        label: _isSignUp ? 'Create account' : 'Sign in',
                        icon: Icons.arrow_forward,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() {
                          _isSignUp = !_isSignUp;
                          _error = null;
                        }),
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign in'
                              : "Don't have an account? Sign up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111B33), AppColors.canvas],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final twoCol = box.maxWidth >= 960;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _brand(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: twoCol
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 540,
                                      ),
                                      child: _hero(),
                                    ),
                                  ),
                                  const SizedBox(width: 72),
                                  _card(),
                                ],
                              )
                            : _card(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'General information only. Not legal advice.',
                      style: AppTheme.mono(size: 10, color: AppColors.faint),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
