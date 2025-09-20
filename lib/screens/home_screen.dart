import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math';
import '../providers/stories_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/premium_story_card.dart';
import 'category_stories_screen.dart';
import 'settings_screen.dart';
import 'story_reader_screen.dart';
import 'favorites_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: _selectedIndex == 0
          ? _buildHomeTab()
          : _selectedIndex == 1
              ? const FavoritesScreen()
              : const SettingsScreen(),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // Hero Section with gradient
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),

        // Quick Categories with count
        SliverToBoxAdapter(
          child: _buildQuickCategories(),
        ),

        // Featured Stories
        SliverToBoxAdapter(
          child: _buildFeaturedSection(),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E),
            Color(0xFF4A148C),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title - kompakt
              const Text(
                'O\'zbek Ertaklari',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
              const SizedBox(height: 4),
              Text(
                'O\'zbekistonning sehrli ertaklari',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCategories() {
    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        final categoryStats = _getCategoryStats(provider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kategoriyalar',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoriesScreen(categoryStats: categoryStats),
                        ),
                      );
                    },
                    child: const Text(
                      'Barchasi →',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                        color: Color(0xFF4A148C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryTile(
                    'Botirlar',
                    categoryStats['Botirlar haqida'] ?? 0,
                    '⚔️',
                    const Color(0xFFD32F2F),
                    () => _navigateToCategory('Botirlar haqida'),
                  ),
                  _buildCategoryTile(
                    'Muhabbat',
                    categoryStats['Muhabbat haqida'] ?? 0,
                    '❤️',
                    const Color(0xFFFF6F00),
                    () => _navigateToCategory('Muhabbat haqida'),
                  ),
                  _buildCategoryTile(
                    'Sehrli',
                    categoryStats['Sehrli ertaklar'] ?? 0,
                    '✨',
                    const Color(0xFF4A148C),
                    () => _navigateToCategory('Sehrli ertaklar'),
                  ),
                  _buildCategoryTile(
                    'Hikmatli',
                    categoryStats['Hikmatli ertaklar'] ?? 0,
                    '📖',
                    const Color(0xFF2E7D32),
                    () => _navigateToCategory('Hikmatli ertaklar'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTile(
    String title,
    int count,
    String icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '$count ertak',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        // Random 10 ta ertak
        final allStories = List.from(provider.stories);
        allStories.shuffle(Random());
        final featured = allStories.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Tavsiya etilgan',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: PremiumStoryCard(
                      story: featured[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StoryReaderScreen(story: featured[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: isDark
                ? const Color(0xFF1E1E1E).withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            selectedItemColor: const Color(0xFF4A148C),
            unselectedItemColor: isDark ? Colors.grey.shade400 : Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Asosiy',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'Sevimlilar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Sozlamalar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _getCategoryStats(StoriesProvider provider) {
    final stats = <String, int>{};
    for (var story in provider.stories) {
      stats[story.category] = (stats[story.category] ?? 0) + 1;
    }
    return stats;
  }

  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryStoriesScreen(category: category),
      ),
    );
  }
}
