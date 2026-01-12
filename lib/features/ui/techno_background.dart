import 'package:flutter/material.dart';

class TechnoBackground extends StatelessWidget {
  final Widget child;
  const TechnoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF020205),
                Color(0xFF0A0A15),
              ],
            ),
          ),
        ),
        // Grid lines painter
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPainter(),
          ),
        ),
        // Ambient glow spots
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00FFC2).withValues(alpha:0.05),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFC2).withValues(alpha:0.1),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD600FF).withValues(alpha:0.05),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD600FF).withValues(alpha:0.1),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        // Content
        SafeArea(child: child),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFC2).withValues(alpha:0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
