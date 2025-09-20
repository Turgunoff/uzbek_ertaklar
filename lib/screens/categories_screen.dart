import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stories_provider.dart';
import '../providers/theme_provider.dart';
import '../models/story.dart'; // Import qo'shing
import '../widgets/premium_story_card.dart';
import 'category_stories_screen.dart';
import 'story_reader_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final Map<String, int> categoryStats;

  const CategoriesScreen({
    Key? key,
    required this.categoryStats,
  }) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Search
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // AppBar qachon collapsed/expanded ekanligini aniqlash
                final double appBarHeight = constraints.biggest.height;
                final double expandedHeight = 160;
                final double collapsedHeight =
                    kToolbarHeight + MediaQuery.of(context).padding.top;

                // Progress: 0.0 (collapsed) to 1.0 (expanded)
                final double progress = ((appBarHeight - collapsedHeight) /
                        (expandedHeight - collapsedHeight))
                    .clamp(0.0, 1.0);

                return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(
                    left: 60,
                    bottom:
                        16 + (progress * 20), // Scroll bilan pastga siljiydi
                  ),
                  title: AnimatedOpacity(
                    opacity:
                        1.0 - progress, // Collapsed da 1.0, expanded da 0.0
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      'Barcha kategoriyalar',
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Katta title (expanded da ko'rinadi)
                            AnimatedOpacity(
                              opacity:
                                  progress, // Expanded da 1.0, collapsed da 0.0
                              duration: const Duration(milliseconds: 100),
                              child: Text(
                                'Barcha kategoriyalar',
                                style: const TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSearchBar(isDark),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Consumer<StoriesProvider>(
            builder: (context, provider, child) {
              final filteredStories = _searchQuery.isEmpty
                  ? provider.stories
                  : provider.stories
                      .where((story) =>
                          story.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          story.category
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();

              if (_searchQuery.isNotEmpty && filteredStories.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildNoResults(context, isDark),
                );
              }

              if (_searchQuery.isNotEmpty) {
                return _buildSearchResults(context, filteredStories, isDark);
              }

              return _buildCategoriesList(context, provider, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 50, // Height qo'shing
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Ertaklarni qidirish...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, bool isDark) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Hech narsa topilmadi',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Boshqa so\'z bilan qidiring',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Story> filteredStories, // Type qo'shing
    bool isDark,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = filteredStories[index];
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
          childCount: filteredStories.length,
        ),
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    StoriesProvider provider,
    bool isDark,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildCategorySection(
            context,
            'Botirlar haqida',
            '⚔️',
            const Color(0xFFD32F2F),
            provider,
            isDark,
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            context,
            'Muhabbat haqida',
            '❤️',
            const Color(0xFFFF6F00),
            provider,
            isDark,
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            context,
            'Sehrli ertaklar',
            '✨',
            const Color(0xFF4A148C),
            provider,
            isDark,
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            context,
            'Hikmatli ertaklar',
            '📖',
            const Color(0xFF2E7D32),
            provider,
            isDark,
          ),
          const SizedBox(height: 100), // Bottom padding
        ]),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    String icon,
    Color color,
    StoriesProvider provider,
    bool isDark,
  ) {
    final stories =
        provider.stories.where((s) => s.category == category).toList();

    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${stories.length})',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              // "Barchasi" button
              if (stories.length > 3)
                TextButton(
                  onPressed: () {
                    // Navigate to category screen with all stories
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryStoriesScreen(category: category),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Barchasi',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 16, color: color),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Scroll Stories
        SizedBox(
          height: 260, // Card height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount:
                stories.length > 6 ? 6 : stories.length, // Max 6 ta ko'rsatish
            itemBuilder: (context, index) {
              return Container(
                width: 160, // Card width
                margin: const EdgeInsets.only(right: 12),
                child: PremiumStoryCard(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
