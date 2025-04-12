// animated_reaction.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedReaction extends StatefulWidget {
  final String emoji;
  final List<Color> colors;

  const AnimatedReaction({
    super.key,
    required this.emoji,
    required this.colors,
  });

  @override
  State<AnimatedReaction> createState() => _AnimatedReactionState();
}

class _AnimatedReactionState extends State<AnimatedReaction>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;

  final List<ParticleModel> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _generateParticles();
    _startAnimations();
  }

  void _initializeControllers() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _initializeAnimations() {
    // Main emoji animations
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_mainController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_mainController);

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: -100.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2) / 12;
      _particles.add(ParticleModel(
        angle: angle,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        speed: _random.nextDouble() * 2 + 1,
        size: _random.nextDouble() * 10 + 5,
      ));
    }
  }

  void _startAnimations() {
    _mainController.forward();
    _rotationController.repeat(reverse: true);
    _particleController.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Particles
          ...List.generate(_particles.length, (index) {
            final particle = _particles[index];
            return AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                final progress = _particleController.value;
                final distance = particle.speed * 150 * progress;
                final opacity = (1 - progress);
                final scale = (1 - progress * 0.5);

                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 +
                      math.cos(particle.angle) * distance,
                  top: MediaQuery.of(context).size.height / 2 +
                      math.sin(particle.angle) * distance,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: particle.size,
                        height: particle.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: particle.color,
                          boxShadow: [
                            BoxShadow(
                              color: particle.color.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main emoji
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                widget.colors.first.withOpacity(0.2),
                                widget.colors.last.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.colors.first.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            widget.emoji,
                            style: const TextStyle(
                              fontSize: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ParticleModel {
  final double angle;
  final Color color;
  final double speed;
  final double size;

  ParticleModel({
    required this.angle,
    required this.color,
    required this.speed,
    required this.size,
  });
}