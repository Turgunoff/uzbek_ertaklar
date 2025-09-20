import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/stories_provider.dart';

class PremiumStoryCard extends StatefulWidget {
  final Story story;
  final VoidCallback onTap;

  const PremiumStoryCard({
    Key? key,
    required this.story,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PremiumStoryCard> createState() => _PremiumStoryCardState();
}

class _PremiumStoryCardState extends State<PremiumStoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(widget.story.category),
                            _getCategoryColor(widget.story.category)
                                .withOpacity(0.6),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),

                    // Decorative icon
                    Center(
                      child: Icon(
                        _getCategoryIcon(widget.story.category),
                        size: 60,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<StoriesProvider>()
                              .toggleFavorite(widget.story.id);
                          if (widget.story.isFavorite) {
                            _heartController.forward();
                          } else {
                            _heartController.reverse();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedBuilder(
                            animation: _heartController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_heartController.value * 0.3),
                                child: Icon(
                                  widget.story.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: widget.story.isFavorite
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.story.category)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryName(widget.story.category),
                          style: GoogleFonts.openSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(widget.story.category),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Title
                      Expanded(
                        child: Text(
                          widget.story.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Read time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.story.readTime,
                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Botirlar haqida':
        return const Color(0xFFD32F2F);
      case 'Muhabbat haqida':
        return const Color(0xFFFF6F00);
      case 'Sehrli ertaklar':
        return const Color(0xFF4A148C);
      case 'Hikmatli ertaklar':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF1A237E);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Botirlar haqida':
        return Icons.shield_rounded;
      case 'Muhabbat haqida':
        return Icons.favorite_rounded;
      case 'Sehrli ertaklar':
        return Icons.auto_fix_high_rounded;
      case 'Hikmatli ertaklar':
        return Icons.menu_book_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'Botirlar haqida':
        return 'Hero Tale';
      case 'Muhabbat haqida':
        return 'Love Story';
      case 'Sehrli ertaklar':
        return 'Magic';
      case 'Hikmatli ertaklar':
        return 'Wisdom';
      default:
        return 'Story';
    }
  }
}
