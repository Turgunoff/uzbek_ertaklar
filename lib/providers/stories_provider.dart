import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';

class StoriesProvider with ChangeNotifier {
  List<Story> _stories = [];
  List<Story> _filteredStories = [];
  String _selectedCategory = 'Hammasi';

  List<Story> get stories =>
      _filteredStories.isEmpty ? _stories : _filteredStories;
  List<Story> get favoriteStories =>
      _stories.where((s) => s.isFavorite).toList();
  String get selectedCategory => _selectedCategory;

  // Kategoriyalar ro'yxati
  List<String> get categories {
    final cats = _stories.map((s) => s.category).toSet().toList();
    cats.insert(0, 'Hammasi');
    return cats;
  }

  // Ertaklarni yuklash
  Future<void> loadStories() async {
    final String response =
        await rootBundle.loadString('assets/stories/stories.json');
    final data = json.decode(response);

    _stories = (data['stories'] as List)
        .map((story) => Story.fromJson(story))
        .toList();

    await _loadFavorites();
    notifyListeners();
  }

  // Sevimlilarga qo'shish/o'chirish
  Future<void> toggleFavorite(String id) async {
    final story = _stories.firstWhere((s) => s.id == id);
    story.isFavorite = !story.isFavorite;
    await _saveFavorites();
    notifyListeners();
  }

  // Kategoriya bo'yicha filter
  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'Hammasi') {
      _filteredStories = [];
    } else {
      _filteredStories = _stories.where((s) => s.category == category).toList();
    }
    notifyListeners();
  }

  // Qidiruv
  void searchStories(String query) {
    if (query.isEmpty) {
      _filteredStories = [];
    } else {
      _filteredStories = _stories
          .where((s) => s.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Sevimlillarni saqlash
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds =
        _stories.where((s) => s.isFavorite).map((s) => s.id).toList();
    await prefs.setStringList('favorites', favoriteIds);
  }

  // Sevimlillarni yuklash
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorites') ?? [];
    for (var story in _stories) {
      story.isFavorite = favoriteIds.contains(story.id);
    }
  }
}
