import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../providers/stories_provider.dart';
import '../widgets/premium_story_card.dart';
import '../widgets/category_card.dart';
import '../widgets/featured_card.dart';
// import 'story_reader_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildHomeTab() : const FavoritesScreen(),
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

        // Categories
        SliverToBoxAdapter(
          child: _buildCategories(),
        ),

        // Featured Stories
        SliverToBoxAdapter(
          child: _buildFeaturedSection(),
        ),

        // All Stories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Barcha ertaklar',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),

        // Stories Grid
        _buildStoriesGrid(),
      ],
    );
  }

  Widget _buildHeroSection() {
    return IntrinsicHeight(
      // Auto height
      child: Container(
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
        child: Stack(
          children: [
            // Background elements
            Positioned(
              top: 40,
              left: 20,
              child: _buildFloatingElement(60),
            ),
            Positioned(
              top: 100,
              right: 40,
              child: _buildFloatingElement(40),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'O\'zbek Ertaklari',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Magical Stories from Uzbekistan',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search Bar
                    _buildGlassSearchBar(),

                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElement(double size) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animationController.value * 20 - 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
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
              context.read<StoriesProvider>().searchStories(value);
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Sehrli ertaklarni qidiring...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        context.read<StoriesProvider>().searchStories('');
                        setState(() {});
                      },
                    )
                  : const Icon(Icons.mic, color: Colors.white),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              CategoryCard(
                title: 'Botirlar',
                subtitle: 'Qahramonlar',
                icon: '⚔️',
                color: const Color(0xFFD32F2F),
                onTap: () => provider.filterByCategory('Botirlar haqida'),
              ),
              CategoryCard(
                title: 'Muhabbat',
                subtitle: 'Sevgi',
                icon: '❤️',
                color: const Color(0xFFFF6F00),
                onTap: () => provider.filterByCategory('Muhabbat haqida'),
              ),
              CategoryCard(
                title: 'Sehrli',
                subtitle: 'Afsonaviy',
                icon: '✨',
                color: const Color(0xFF4A148C),
                onTap: () => provider.filterByCategory('Sehrli ertaklar'),
              ),
              CategoryCard(
                title: 'Hikmatli',
                subtitle: 'Donolik',
                icon: '📖',
                color: const Color(0xFF2E7D32),
                onTap: () => provider.filterByCategory('Hikmatli ertaklar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        final featured = provider.stories.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tavsiya etilgan ertaklar',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  return FeaturedCard(
                    story: featured[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // builder: (_) => StoryReaderScreen(story: featured[index]),
                          builder: (_) => Container(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildStoriesGrid() {
    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final story = provider.stories[index];
                return PremiumStoryCard(
                  story: story,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (_) => StoryReaderScreen(story: story),
                        builder: (_) => Container(),
                      ),
                    );
                  },
                );
              },
              childCount: provider.stories.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            backgroundColor: Colors.white.withOpacity(0.9),
            selectedItemColor: const Color(0xFF4A148C),
            unselectedItemColor: Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_stories_rounded),
                label: 'Ertaklar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'Sevimlilar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
