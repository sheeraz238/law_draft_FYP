import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Chhota pill badge (court, tag, status)
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, {super.key, this.color = AppColors.amberHover});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(64)),
      ),
      child: Text(text, style: AppTheme.mono(size: 10, color: color)),
    );
  }
}

/// Amber icon wala chhota dibba
class IconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  const IconBox(this.icon, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Icon(icon, size: size * 0.5, color: AppColors.amber),
    );
  }
}

/// "01", "02" jaisa numbered badge
class NumberBadge extends StatelessWidget {
  final String text;
  const NumberBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2D12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x40E5A93C)),
      ),
      child: Text(
        text,
        style: AppTheme.mono(
          size: 12,
          weight: FontWeight.w600,
          color: AppColors.amber,
        ),
      ),
    );
  }
}

/// Sunehri gradient wala bada button (login jaisi jagahon ke liye)
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: (enabled || loading) ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDF9B28), Color(0xFFF7D988), Color(0xFFDF9B28)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.canvas,
                      ),
                    )
                  else ...[
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.canvas,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 18, color: AppColors.canvas),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
