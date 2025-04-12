// particles_painter.dart
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';

class ParticlesPainter extends CustomPainter {
  final double progress;
  final Random _random = Random();
  final List<Particle> _particles = [];
  static const int particleCount = 50;

  ParticlesPainter({required this.progress}) {
    if (_particles.isEmpty) {
      _initializeParticles();
    }
  }

  void _initializeParticles() {
    for (var i = 0; i < particleCount; i++) {
      _particles.add(Particle(
        position: Offset(
          _random.nextDouble(),
          _random.nextDouble(),
        ),
        velocity: Offset(
          _random.nextDouble() * 0.2 - 0.1,
          _random.nextDouble() * 0.2 - 0.1,
        ),
        size: _random.nextDouble() * 3 + 1,
        opacity: _random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (var particle in _particles) {
      // Update particle position
      particle.position += particle.velocity;

      // Wrap particles around screen
      if (particle.position.dx < 0) particle.position = Offset(1, particle.position.dy);
      if (particle.position.dx > 1) particle.position = Offset(0, particle.position.dy);
      if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, 1);
      if (particle.position.dy > 1) particle.position = Offset(particle.position.dx, 0);

      // Calculate wave effect
      final wave = math.sin(progress * 2 * math.pi + particle.position.dx * math.pi) * 0.1;
      final yPos = particle.position.dy + wave;

      // Draw particle with dynamic color
      paint.color = Colors.tealAccent.withOpacity(
          particle.opacity * (0.5 + 0.5 * math.sin(progress * 2 * math.pi))
      );

      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          yPos * size.height,
        ),
        particle.size,
        paint,
      );

      // Optional: Draw connecting lines between nearby particles
      for (var other in _particles) {
        final distance = (particle.position - other.position).distance;
        if (distance < 0.1) {
          paint.color = Colors.tealAccent.withOpacity(
              (0.1 - distance) * particle.opacity * 0.5
          );
          canvas.drawLine(
            Offset(particle.position.dx * size.width, yPos * size.height),
            Offset(other.position.dx * size.width, other.position.dy * size.height),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}

class Particle {
  Offset position;
  final Offset velocity;
  final double size;
  final double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
  });
}