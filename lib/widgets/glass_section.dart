import 'package:flutter/material.dart';
import 'glass_card.dart';

class GlassSection extends StatelessWidget {
  const GlassSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: scheme.primary, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
