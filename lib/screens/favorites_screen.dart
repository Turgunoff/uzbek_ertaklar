import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stories_provider.dart';
import '../widgets/story_card.dart';
import 'story_reader_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        final favorites = provider.favoriteStories;

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sevimli ertaklar yo\'q',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final story = favorites[index];
            return StoryCard(
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
        );
      },
    );
  }
}
