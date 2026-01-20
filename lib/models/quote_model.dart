class Quote {
  final String id;
  final String text;
  final String author;
  final String category;
  bool isFavorite;

  Quote({
    required this.text,
    required this.author,
    String? id,
    this.category = 'General',
    this.isFavorite = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Factory constructor to create a Quote from JSON (API response)
  factory Quote.fromJson(Map<String, dynamic> json) {
    // ZenQuotes API uses 'q' for quote and 'a' for author
    return Quote(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['q'] ?? json['text'] ?? 'Unknown Quote',
      author: json['a'] ?? json['author'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Convert Quote to JSON (for saving to Shared Preferences/Database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'isFavorite': isFavorite,
    };
  }
}