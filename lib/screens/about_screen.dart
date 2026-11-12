import 'package:flutter/material.dart';
import '../core/app_info.dart';
import '../core/app_theme.dart';
import '../widgets/ui_kit.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _steps = [
    ('Select a template', 'Pick a legal draft from the library.'),
    ('Fill in the details', 'Answer the guided form, party by party.'),
    ('Preview the draft', 'Check the generated text before you export.'),
    ('Download DOCX', 'Get an editable Word file you can review.'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Pill('FINAL YEAR PROJECT', color: AppColors.amber),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        style: t.headlineLarge,
                        children: [
                          const TextSpan(text: 'About '),
                          TextSpan(
                            text: AppInfo.appName,
                            style: t.headlineLarge?.copyWith(
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppInfo.tagline,
                      style: t.bodyLarge?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'A free platform where advocates and law students generate '
                      'structured legal drafts by filling guided forms, search '
                      'case laws, and use calculators for inheritance and '
                      'property tax.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('How it works', style: t.titleLarge),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, box) {
                final cols = box.maxWidth >= 760
                    ? 4
                    : (box.maxWidth >= 480 ? 2 : 1);
                final w = (box.maxWidth - 12 * (cols - 1)) / cols;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < _steps.length; i++)
                      SizedBox(
                        width: w,
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NumberBadge('${i + 1}'.padLeft(2, '0')),
                                const SizedBox(height: 12),
                                Text(_steps[i].$1, style: t.titleMedium),
                                const SizedBox(height: 4),
                                Text(_steps[i].$2, style: t.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project', style: t.titleLarge),
                    const SizedBox(height: 12),
                    for (final d in AppInfo.developers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 18,
                              color: AppColors.amber,
                            ),
                            const SizedBox(width: 8),
                            Text('Developer: $d'),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 18,
                          color: AppColors.amber,
                        ),
                        const SizedBox(width: 8),
                        Text('Supervisor: ${AppInfo.supervisor}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Legal disclaimer: this platform does not give legal advice '
                  'or legal representation. Drafts are generated only from the '
                  'information you enter. Please review, edit and verify every '
                  'document before using or submitting it. Using this platform '
                  'does not create a lawyer-client relationship.',
                  style: TextStyle(
                    height: 1.55,
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
