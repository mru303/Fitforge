import 'dart:math';
import 'package:flutter/material.dart';

class FitForgeLogo extends StatelessWidget {
  const FitForgeLogo({super.key, this.size = 52, this.showLabel = false});

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ClipPath(
            clipper: _HexagonClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: size * 0.16,
                    top: size * 0.12,
                    child: Icon(
                      Icons.bolt_rounded,
                      size: size * 0.24,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  Text(
                    'F',
                    style: TextStyle(
                      fontSize: size * 0.46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 12),
          const Text(
            'FitForge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ],
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = width / 2;

    const angle = 2 * 3.141592653589793 / 6;
    for (var i = 0; i < 6; i++) {
      final x = centerX + radius * cos(angle * i - 3.141592653589793 / 6);
      final y = centerY + radius * sin(angle * i - 3.141592653589793 / 6);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
