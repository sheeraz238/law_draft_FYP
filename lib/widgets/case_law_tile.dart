import 'package:flutter/material.dart';
import '../models/case_law.dart';

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
    return Card(
      child: ListTile(
        title: Text(caseLaw.title),
        subtitle: Text(
            '${caseLaw.citation}  •  ${caseLaw.court}  •  ${caseLaw.year ?? '-'}'),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : null,
          ),
          onPressed: onToggleFavorite,
        ),
        onTap: () => _showDetails(context),
      ),
    );
  }
}