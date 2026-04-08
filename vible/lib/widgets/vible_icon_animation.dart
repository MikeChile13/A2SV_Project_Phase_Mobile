import 'package:flutter/material.dart';
import 'dart:math' as math;

class VibleIconAnimation extends StatefulWidget {
  final double size;
  final VoidCallback? onCompleted;
  const VibleIconAnimation({super.key, this.size = 240, this.onCompleted});

  @override
  State<VibleIconAnimation> createState() => _VibleIconAnimationState();
}

class _VibleIconAnimationState extends State<VibleIconAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animations
  late Animation<double> _ringRotation;
  late Animation<double> _dotsScale;
  late Animation<double> _crossScale;
  late Animation<double> _crossOpacity;
  late List<Animation<double>> _letterOpacities;
  late Animation<double> _textYOffset;
  late Animation<double> _textOpacity;

  final String _veritas = "VERITAS";

  @override
  void initState() {
    super.initState();
    // Total duration matching the longest delay + duration in your TSX (approx 2.8s)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    // 1. Ring Rotation (0s - 1.5s)
    _ringRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.53, curve: Curves.easeInOut),
      ),
    );

    // 2. Dots Scale (0.3s - 0.6s)
    _dotsScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.21, curve: Curves.easeOut),
      ),
    );

    // 3. Cross Appearance (0.8s - 1.3s)
    _crossScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.46, curve: Curves.elasticOut),
      ),
    );
    _crossOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.35, curve: Curves.easeIn),
      ),
    );

    // 4. Veritas Letters (Staggered starting at 1.5s)
    _letterOpacities = List.generate(_veritas.length, (index) {
      double start = 0.53 + (index * 0.03); // Stagger
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, start + 0.07, curve: Curves.linear),
        ),
      );
    });

    // 5. King James Bible Text (2.2s - 2.8s)
    _textYOffset = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    // Notify parent when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });
  }
  
  @override
  void reassemble() {
    // Called on hot reload / soft reset. Restart the animation so it replays.
    super.reassemble();
    if (mounted) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: ViblePainter(
                ringRotation: _ringRotation.value,
                dotsScale: _dotsScale.value,
                crossScale: _crossScale.value,
                crossOpacity: _crossOpacity.value,
                letterOpacities: _letterOpacities.map((a) => a.value).toList(),
                veritas: _veritas,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _textYOffset.value),
              child: Opacity(
                opacity: _textOpacity.value,
                child: const Text(
                  'King James Bible',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ViblePainter extends CustomPainter {
  final double ringRotation;
  final double dotsScale;
  final double crossScale;
  final double crossOpacity;
  final List<double> letterOpacities;
  final String veritas;

  ViblePainter({
    required this.ringRotation,
    required this.dotsScale,
    required this.crossScale,
    required this.crossOpacity,
    required this.letterOpacities,
    required this.veritas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35; // 70/200 ratio
    final scaleFactor = size.width / 200;

    // 1. Background Circle
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF18181B), Color(0xFF27272A), Color(0xFF18181B)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Decorative Ring
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(ringRotation);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scaleFactor
      ..shader = const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 65 * scaleFactor))
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset.zero, 65 * scaleFactor, ringPaint);
    canvas.restore();

    // 3. Cross
    if (crossOpacity > 0) {
      canvas.save();
      canvas.translate(center.dx, center.dy - (5 * scaleFactor));
      canvas.scale(crossScale);
      
      final crossPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9D5FF), Color(0xFFD8B4FE), Color(0xFFC084FC)],
        ).createShader(Rect.fromLTWH(-16, -28, 32, 46))
        ..color = Colors.white.withValues(alpha: crossOpacity);

      // Vertical bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-3 * scaleFactor, -28 * scaleFactor, 6 * scaleFactor, 46 * scaleFactor),
          Radius.circular(2 * scaleFactor),
        ),
        crossPaint,
      );
      // Horizontal bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-16 * scaleFactor, -16 * scaleFactor, 32 * scaleFactor, 6 * scaleFactor),
          Radius.circular(2 * scaleFactor),
        ),
        crossPaint,
      );
      canvas.restore();
    }

    // 4. Veritas Text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double startX = center.dx - (40 * scaleFactor); // Manual centering adjustment
    
    for (int i = 0; i < veritas.length; i++) {
      if (letterOpacities[i] > 0) {
        textPainter.text = TextSpan(
          text: veritas[i],
          style: TextStyle(
            color: const Color(0xFFD8B4FE).withValues(alpha: letterOpacities[i]),
            fontSize: 12 * scaleFactor,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w500,
            letterSpacing: 3 * scaleFactor,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(startX + (i * 12 * scaleFactor), center.dy + (25 * scaleFactor)));
      }
    }

    // 5. Decorative Dots
    final dotPaint = Paint()..color = const Color(0xFFA78BFA).withValues(alpha: 0.6);
    if (dotsScale > 0) {
      canvas.drawCircle(Offset(center.dx, center.dy - (65 * scaleFactor)), 2 * scaleFactor * dotsScale, dotPaint);
      canvas.drawCircle(Offset(center.dx, center.dy + (65 * scaleFactor)), 2 * scaleFactor * dotsScale, dotPaint);
    }
  }

  @override
  bool shouldRepaint(ViblePainter oldDelegate) => true;
}