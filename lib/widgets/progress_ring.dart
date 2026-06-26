import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final Color accent;
  final IconData icon;
  final String? label;

  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.accent,
    required this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: 8,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                strokeCap: StrokeCap.round,
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent, size: size * 0.28),
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
