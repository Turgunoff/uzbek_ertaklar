import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';
import '../providers/stories_provider.dart';
import '../providers/theme_provider.dart';

class StoryReaderScreen extends StatefulWidget {
  final Story story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen>
    with TickerProviderStateMixin {
  double _fontSize = 18.0;
  final ScrollController _scrollController = ScrollController();
  bool _isAutoScrolling = false;
  AnimationController? _animationController;
  Animation<double>? _scrollAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _saveReadingHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 18.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
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
          style: const TextStyle(
            fontFamily: 'Playfair Display',
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

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
                    style: TextStyle(
                      fontFamily: 'Open Sans',
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
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.story.readTime,
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Story Description
            if (widget.story.description.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(widget.story.category).withOpacity(0.1),
                      _getCategoryColor(widget.story.category)
                          .withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getCategoryColor(widget.story.category)
                        .withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _getCategoryColor(widget.story.category),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ertak haqida qisqacha',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(widget.story.category),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.story.description,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        height: 1.6,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Story Content
            SelectableText(
              widget.story.content,
              style: TextStyle(
                fontFamily: 'Merriweather',
                fontSize: _fontSize,
                height: 1.8,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
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
                      'Ertak tugadi. Rahmat!',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
              color: isDark ? Colors.white : Colors.black,
            ),

            Text(
              '${_fontSize.toInt()}',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
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
              color: isDark ? Colors.white : Colors.black,
            ),

            // Divider
            Container(
              height: 30,
              width: 1,
              color: Colors.grey.shade300,
            ),

            // Dark Mode Toggle
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
              color: isDark ? Colors.white : Colors.black,
            ),

            // Play/Pause button
            IconButton(
              icon: Icon(
                _isAutoScrolling ? Icons.pause : Icons.play_arrow,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: _toggleAutoScroll,
            ),
          ],
        ),
      ),
    );
  }

  void _shareStory() {
    final shareText = '''
📚 ${widget.story.title}

${widget.story.content.length > 200 ? '${widget.story.content.substring(0, 200)}...' : widget.story.content}

📖 O'zbek Ertaklari ilovasida barcha ertaklarni o'qing!
🔗 https://play.google.com/store/apps/details?id=uz.uzbek.uzbek_ertaklar
''';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));

    // Show snackbar with share options
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Matn nusxalandi! Boshqa ilovalarda ulashing'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // This will open share dialog on most Android devices
            Clipboard.setData(ClipboardData(text: shareText));
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startAutoScroll() {
    if (_isAutoScrolling) return;

    setState(() {
      _isAutoScrolling = true;
    });

    _animationController = AnimationController(
      duration: Duration(seconds: widget.story.content.length ~/ 40),
      vsync: this,
    );

    _scrollAnimation = Tween<double>(
      begin: _scrollController.offset,
      end: _scrollController.position.maxScrollExtent,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    _scrollAnimation!.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollAnimation!.value);
      }
    });

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAutoScrolling = false;
        });
        _animationController?.dispose();
        _animationController = null;
      }
    });

    _animationController!.forward();
  }

  void _pauseAutoScroll() {
    if (_animationController != null) {
      _animationController!.stop();
      _animationController?.dispose();
      _animationController = null;
    }
    setState(() {
      _isAutoScrolling = false;
    });
  }

  void _toggleAutoScroll() {
    if (_isAutoScrolling) {
      _pauseAutoScroll();
    } else {
      _startAutoScroll();
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
