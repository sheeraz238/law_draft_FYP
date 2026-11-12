import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/case_law.dart';
import 'ui_kit.dart';

class CaseLawTile extends StatelessWidget {
  final CaseLaw caseLaw;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const CaseLawTile({
    super.key,
    required this.caseLaw,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(caseLaw.title),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Citation: ${caseLaw.citation}'),
                Text('Court: ${caseLaw.court}'),
                Text('Year: ${caseLaw.year ?? '-'}'),
                const SizedBox(height: 12),
                Text(caseLaw.summary),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (caseLaw.citation.isNotEmpty) Pill(caseLaw.citation),
                        if (caseLaw.court.isNotEmpty)
                          Pill(
                            caseLaw.court.toUpperCase(),
                            color: const Color(0xFF60A5FA),
                          ),
                        if (caseLaw.year != null)
                          Pill('${caseLaw.year}', color: AppColors.muted),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isFavorite ? 'Remove from favorites' : 'Save',
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorite ? AppColors.amber : AppColors.muted,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(caseLaw.title, style: t.titleLarge),
              if (caseLaw.summary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SUMMARY',
                        style: AppTheme.mono(
                          size: 10,
                          weight: FontWeight.w600,
                          color: AppColors.amber,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        caseLaw.summary,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, height: 1.55),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
