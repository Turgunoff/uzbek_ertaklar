import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stories_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/premium_story_card.dart';
import 'story_reader_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: Consumer<StoriesProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favoriteStories;

          if (favorites.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return CustomScrollView(
            slivers: [
              // Header with gradient
              SliverToBoxAdapter(
                child: _buildHeader(context, favorites.length, isDark),
              ),

              // Favorites count and stats
              SliverToBoxAdapter(
                child: _buildStats(context, favorites, isDark),
              ),

              // Stories grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final story = favorites[index];
                      return PremiumStoryCard(
                        story: story,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoryReaderScreen(story: story),
                            ),
                          );
                        },
                      );
                    },
                    childCount: favorites.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated heart icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? Colors.white : Colors.grey.shade100)
                    .withOpacity(0.1),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.grey.shade300)
                      .withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'Sevimli ertaklar yo\'q',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Sizga yoqqan ertaklarni sevimlilar ro\'yxatiga qo\'shing',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Action button
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A148C).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to home tab
                  // TODO: Implement navigation to home tab
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Ertaklarni ko\'rish',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Sevimli ertaklar',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                '$count ta sevimli ertak',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 20),

              // Decorative elements
              Row(
                children: [
                  _buildDecorativeIcon(Icons.favorite_rounded, 0.8),
                  const SizedBox(width: 12),
                  _buildDecorativeIcon(Icons.auto_stories_rounded, 0.6),
                  const SizedBox(width: 12),
                  _buildDecorativeIcon(Icons.star_rounded, 0.7),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeIcon(IconData icon, double opacity) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity * 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white.withOpacity(opacity),
        size: 20,
      ),
    );
  }

  Widget _buildStats(BuildContext context, List favorites, bool isDark) {
    // Calculate category distribution
    final categoryStats = <String, int>{};
    for (var story in favorites) {
      categoryStats[story.category] = (categoryStats[story.category] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistika',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 16),

          // Category distribution
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categoryStats.entries.map((entry) {
              return _buildCategoryChip(entry.key, entry.value, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, int count, bool isDark) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    final name = _getCategoryName(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$name ($count)',
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
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
        return 'Qahramon';
      case 'Muhabbat haqida':
        return 'Sevgi';
      case 'Sehrli ertaklar':
        return 'Sehrli';
      case 'Hikmatli ertaklar':
        return 'Donolik';
      default:
        return 'Ertak';
    }
  }
}
