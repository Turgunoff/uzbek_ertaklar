import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stories_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/premium_story_card.dart';
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
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Barcha kategoriyalar',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: _buildSearchBar(isDark),
                  ),
                ),
              ),
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Boshqa so\'z bilan qidiring',
              style: GoogleFonts.openSans(
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
      BuildContext context, List filteredStories, bool isDark) {
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
      BuildContext context, StoriesProvider provider, bool isDark) {
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
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${stories.length})',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
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
