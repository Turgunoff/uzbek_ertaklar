import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stories_provider.dart';
import '../widgets/premium_story_card.dart';
import 'story_reader_screen.dart';

class CategoryStoriesScreen extends StatelessWidget {
  final String category;

  const CategoryStoriesScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _getCategoryTitle(category),
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _getCategoryColor(category),
        elevation: 0,
      ),
      body: Consumer<StoriesProvider>(
        builder: (context, provider, child) {
          final stories =
              provider.stories.where((s) => s.category == category).toList();

          if (stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu kategoriyada ertaklar yo\'q',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and count
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getCategoryIcon(category),
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stories.length} ta ertak',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            _getCategorySubtitle(category),
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Stories Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    return PremiumStoryCard(
                      story: stories[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StoryReaderScreen(story: stories[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'Botirlar haqida':
        return 'Botirlar';
      case 'Muhabbat haqida':
        return 'Muhabbat';
      case 'Sehrli ertaklar':
        return 'Sehrli';
      case 'Hikmatli ertaklar':
        return 'Hikmatli';
      default:
        return category;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Botirlar haqida':
        return '⚔️';
      case 'Muhabbat haqida':
        return '❤️';
      case 'Sehrli ertaklar':
        return '✨';
      case 'Hikmatli ertaklar':
        return '📖';
      default:
        return '📚';
    }
  }

  String _getCategorySubtitle(String category) {
    switch (category) {
      case 'Botirlar haqida':
        return 'Qahramonlik va jasorat haqida';
      case 'Muhabbat haqida':
        return 'Sevgi va muhabbat haqida';
      case 'Sehrli ertaklar':
        return 'Sehrli va afsonaviy hikoyalar';
      case 'Hikmatli ertaklar':
        return 'Donolik va hikmatliylar';
      default:
        return category;
    }
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
}
