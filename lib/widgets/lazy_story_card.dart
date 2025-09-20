import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/stories_provider.dart';

class LazyStoryCard extends StatefulWidget {
  final Story story;
  final VoidCallback onTap;
  final int index;

  const LazyStoryCard({
    Key? key,
    required this.story,
    required this.onTap,
    this.index = 0,
  }) : super(key: key);

  @override
  State<LazyStoryCard> createState() => _LazyStoryCardState();
}

class _LazyStoryCardState extends State<LazyStoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _heartController;
  bool _isPressed = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    // Heart animation controller
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Delayed start based on index for stagger effect
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
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
                    // Gradient background with shimmer effect
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
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

                    // Decorative icon with animation
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Opacity(
                              opacity: value,
                              child: Icon(
                                _getCategoryIcon(widget.story.category),
                                size: 60,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          );
                        },
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
