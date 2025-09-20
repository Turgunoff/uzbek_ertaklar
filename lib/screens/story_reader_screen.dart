import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';
import '../providers/stories_provider.dart';

class StoryReaderScreen extends StatefulWidget {
  final Story story;

  const StoryReaderScreen({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  double _fontSize = 18.0;
  bool _isDarkMode = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _saveReadingHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 18.0;
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setBool('darkMode', _isDarkMode);
  }

  Future<void> _saveReadingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('reading_history') ?? [];
    history.remove(widget.story.id);
    history.insert(0, widget.story.id);
    if (history.length > 10) history.removeLast();
    await prefs.setStringList('reading_history', history);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            _buildContent(),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _getCategoryColor(widget.story.category),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Favorite button
        IconButton(
          icon: Icon(
            widget.story.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () {
            context.read<StoriesProvider>().toggleFavorite(widget.story.id);
            setState(() {});
          },
        ),

        // Share button
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareStory,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.story.title,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getCategoryColor(widget.story.category),
                _getCategoryColor(widget.story.category).withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(widget.story.category),
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(widget.story.category)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.story.category,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(widget.story.category),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: _isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.story.readTime,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: _isDarkMode ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Story Content
            SelectableText(
              widget.story.content,
              style: GoogleFonts.merriweather(
                fontSize: _fontSize,
                height: 1.8,
                color: _isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 40),

            // Story End Decoration
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      _getCategoryColor(widget.story.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 40,
                      color: _getCategoryColor(widget.story.category),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ertak tugadi',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(widget.story.category),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Font Size Controls
            IconButton(
              icon: const Icon(Icons.text_decrease),
              onPressed: () {
                if (_fontSize > 14) {
                  setState(() => _fontSize -= 2);
                  _saveSettings();
                }
              },
              color: _isDarkMode ? Colors.white : Colors.black,
            ),

            Text(
              '${_fontSize.toInt()}',
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),

            IconButton(
              icon: const Icon(Icons.text_increase),
              onPressed: () {
                if (_fontSize < 28) {
                  setState(() => _fontSize += 2);
                  _saveSettings();
                }
              },
              color: _isDarkMode ? Colors.white : Colors.black,
            ),

            // Divider
            Container(
              height: 30,
              width: 1,
              color: Colors.grey.shade300,
            ),

            // Dark Mode Toggle
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() => _isDarkMode = !_isDarkMode);
                _saveSettings();
              },
              color: _isDarkMode ? Colors.white : Colors.black,
            ),

            // Auto Scroll
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _startAutoScroll,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),

            // Bookmark
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // TODO: Implement bookmark
              },
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  void _shareStory() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: ${widget.story.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startAutoScroll() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: widget.story.content.length ~/ 20),
      curve: Curves.linear,
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
}
