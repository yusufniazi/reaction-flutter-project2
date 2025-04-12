// reaction_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animated_reaction.dart';

class ReactionData {
  final String emoji;
  final String label;
  final List<Color> colors;

  const ReactionData({
    required this.emoji,
    required this.label,
    required this.colors,
  });
}

class ReactionPanel extends StatelessWidget {
  final Offset position;

  const ReactionPanel({super.key, required this.position});

  static const List<ReactionData> reactions = [
    ReactionData(
      emoji: '❤️',
      label: 'Love',
      colors: [Color(0xFFFF4B6E), Color(0xFFFF758C)],
    ),
    ReactionData(
      emoji: '😂',
      label: 'Haha',
      colors: [Color(0xFFFFB847), Color(0xFFFFD447)],
    ),
    ReactionData(
      emoji: '👍',
      label: 'Like',
      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    ),
    ReactionData(
      emoji: '🎉',
      label: 'Party',
      colors: [Color(0xFF9333EA), Color(0xFFA855F7)],
    ),
    ReactionData(
      emoji: '🔥',
      label: 'Fire',
      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    ),
    ReactionData(
      emoji: '😍',
      label: 'Love it',
      colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx - 120, // Reduced from 180
          top: position.dy - 100,  // Reduced from 150
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced padding
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(24), // Reduced radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: reactions.map((reaction) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2), // Reduced spacing
                    child: CompactAnimatedEmoji(
                      emoji: reaction.emoji,
                      label: reaction.label,
                      colors: reaction.colors,
                      onSelected: () {
                        Navigator.pop(context);
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.transparent,
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return AnimatedReaction(
                              emoji: reaction.emoji,
                              colors: reaction.colors,
                            );
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CompactAnimatedEmoji extends StatefulWidget {
  final String emoji;
  final String label;
  final List<Color> colors;
  final VoidCallback onSelected;

  const CompactAnimatedEmoji({
    super.key,
    required this.emoji,
    required this.label,
    required this.colors,
    required this.onSelected,
  });

  @override
  State<CompactAnimatedEmoji> createState() => _CompactAnimatedEmojiState();
}

class _CompactAnimatedEmojiState extends State<CompactAnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150), // Faster animation
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate( // Reduced scale
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onSelected();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(6), // Reduced padding
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isHovered
                      ? LinearGradient(
                    colors: widget.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: _isHovered ? null : Colors.transparent,
                ),
                child: Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 24), // Reduced font size
                ),
              ),
            ),
            if (_isHovered) ...[
              const SizedBox(height: 2), // Reduced spacing
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: widget.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 10, // Reduced font size
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}