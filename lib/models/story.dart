class Story {
  final String id;
  final String title;
  final String category;
  final String content;
  final String readTime;
  final String description;
  bool isFavorite;

  Story({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.readTime,
    required this.description,
    this.isFavorite = false,
  });

  // JSON dan Story yaratish
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      content: json['content'],
      readTime: json['readTime'],
      description: json['description'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Story ni JSON ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'readTime': readTime,
      'description': description,
      'isFavorite': isFavorite,
    };
  }
}
