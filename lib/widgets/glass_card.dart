import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.opacity,
    this.borderOpacity,
  });

  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? opacity;
  final double? borderOpacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fillOpacity = opacity ?? (isDark ? 0.5 : 0.78);
    final double strokeOpacity = borderOpacity ?? (isDark ? 0.15 : 0.6);
    final Color base =
        isDark ? Colors.white : Colors.white;
    final Color stroke =
        isDark ? Colors.white.withValues(alpha: strokeOpacity) : Colors.white.withValues(alpha: strokeOpacity);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: base.withValues(alpha: fillOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: stroke,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
