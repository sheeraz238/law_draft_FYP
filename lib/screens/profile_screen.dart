import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../widgets/ui_kit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _firm = TextEditingController();
  final _enrollment = TextEditingController();
  final _whatsapp = TextEditingController();

  UserProfile? _profile;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _firm.dispose();
    _enrollment.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await _service.fetch();
      _name.text = p.fullName;
      _city.text = p.city;
      _firm.text = p.lawFirm;
      _enrollment.text = p.enrollmentNo;
      _whatsapp.text = p.whatsapp;
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Profile load nahi hui: $e';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.update({
        'full_name': _name.text.trim(),
        'city': _city.text.trim(),
        'law_firm': _firm.text.trim(),
        'enrollment_no': _enrollment.text.trim(),
        'whatsapp': _whatsapp.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

   Widget _creditCard(String label, int value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconBox(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.mono(
                        size: 10,
                        weight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
  }) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }
    final p = _profile!;
    final t = Theme.of(context).textTheme;
    final initial = p.fullName.isEmpty
        ? '?'
        : p.fullName.substring(0, 1).toUpperCase();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xFF3A2D12),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.fullName, style: t.headlineSmall),
                          const SizedBox(height: 2),
                          Text(_service.email, style: t.bodySmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Pill(
                                p.lawFirm.isEmpty
                                    ? 'INDIVIDUAL'
                                    : p.lawFirm.toUpperCase(),
                              ),
                              if (p.city.isNotEmpty)
                                Pill(
                                  p.city.toUpperCase(),
                                  color: const Color(0xFF60A5FA),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (AppConfig.enableCredits)
              Row(
                children: [
                  _creditCard(
                    'Drafts left',
                    p.draftCredits,
                    Icons.description_outlined,
                  ),
                  _creditCard(
                    'Case law searches',
                    p.caselawCredits,
                    Icons.gavel_outlined,
                  ),
                ],
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const NumberBadge('01'),
                          const SizedBox(width: 12),
                          Text('Personal information', style: t.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, box) {
                          final w = box.maxWidth >= 560
                              ? (box.maxWidth - 16) / 2
                              : box.maxWidth;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 14,
                            children: [
                              SizedBox(
                                width: w,
                                child: _field(
                                  _name,
                                  'Full name',
                                  required: true,
                                ),
                              ),
                              SizedBox(
                                width: w,
                                child: _field(_firm, 'Law firm'),
                              ),
                              SizedBox(width: w, child: _field(_city, 'City')),
                              SizedBox(
                                width: w,
                                child: _field(_enrollment, 'Enrollment no.'),
                              ),
                              SizedBox(
                                width: w,
                                child: _field(_whatsapp, 'WhatsApp'),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.canvas,
                                  ),
                                )
                              : const Text('Save changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
