// Quote ka structure define karta hai

class Quote {
  final String id;
  final String text;
  final String author;
  final String category;
  bool isFavorite;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    this.isFavorite = false,
  });

  // JSON se Quote object banana
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      // ZenQuotes uses 'q' for text and 'a' for author. 
      // Fallback to 'id' or generate one from text hash if not present.
      id: json['id'] ?? json['q'].hashCode.toString(),
      text: json['q'] ?? json['text'] ?? 'Unknown Quote',
      author: json['a'] ?? json['author'] ?? 'Unknown Author',
      // ZenQuotes often sends 'c' or nothing for category in random. 
      // We can default to 'General' or use 'c'.
      category: json['c'] ?? json['category'] ?? 'General',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Quote ko JSON mein convert karna (save ke liye)
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