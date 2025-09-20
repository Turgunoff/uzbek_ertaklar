import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stories_provider.dart';
import '../widgets/premium_story_card.dart';
import 'story_reader_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final Map<String, int> categoryStats;

  const CategoriesScreen({
    Key? key,
    required this.categoryStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Barcha kategoriyalar',
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Consumer<StoriesProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCategorySection(
                context,
                'Botirlar haqida',
                '⚔️',
                const Color(0xFFD32F2F),
                provider,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                context,
                'Muhabbat haqida',
                '❤️',
                const Color(0xFFFF6F00),
                provider,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                context,
                'Sehrli ertaklar',
                '✨',
                const Color(0xFF4A148C),
                provider,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                context,
                'Hikmatli ertaklar',
                '📖',
                const Color(0xFF2E7D32),
                provider,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    String icon,
    Color color,
    StoriesProvider provider,
  ) {
    final stories =
        provider.stories.where((s) => s.category == category).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${stories.length})',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            return PremiumStoryCard(
              story: stories[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryReaderScreen(story: stories[index]),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
