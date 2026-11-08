import 'package:flutter/material.dart';
import '../core/app_info.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _steps = [
    'Select a legal draft template',
    'Fill in the required information',
    'Preview the generated draft',
    'Download the editable DOCX file',
  ];

  Widget _card(BuildContext context, String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'About ${AppInfo.appName}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(AppInfo.tagline),
            const SizedBox(height: 16),
            _card(context, 'What it does', const [
              Text(
                'A free platform where advocates, law students and the general '
                'public generate structured legal drafts by filling guided forms, '
                'search case laws, and use calculators for inheritance and '
                'property tax.',
              ),
            ]),
            _card(context, 'How it works', [
              for (var i = 0; i < _steps.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 12,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(_steps[i]),
                ),
            ]),
            _card(context, 'Project', [
              Text('Final Year Project'),
              for (final d in AppInfo.developers) Text('Developer: $d'),
              Text('Supervisor: ${AppInfo.supervisor}'),
            ]),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Legal disclaimer: this platform does not give legal advice '
                  'or legal representation. Drafts are generated only from the '
                  'information you enter. Please review, edit and verify every '
                  'document before using or submitting it. Using this platform '
                  'does not create a lawyer-client relationship.',
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
