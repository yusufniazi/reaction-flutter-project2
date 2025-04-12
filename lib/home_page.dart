import 'package:emoji_reaction/particles_painter.dart';
import 'package:emoji_reaction/reaction_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmojiReactionHome extends StatefulWidget {
  const EmojiReactionHome({super.key});

  @override
  State<EmojiReactionHome> createState() => _EmojiReactionHomeState();
}

class _EmojiReactionHomeState extends State<EmojiReactionHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Hero(
          tag: 'app_title',
          child: Text(
            'Reactions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF1A1A1A).withOpacity(0.8),
                        Colors.teal.withOpacity(0.2),
                      ],
                      transform: GradientRotation(
                        _backgroundController.value * 2 * 3.14159,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Animated particles layer
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  key: _backgroundKey,
                  painter: ParticlesPainter(
                    progress: _backgroundController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji button wrapper with additional effects
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const ReactionButton(),
                ),
                // Optional hint text
                const SizedBox(height: 40),
                Text(
                  'Tap to react',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}