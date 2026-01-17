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
      id: json['id'],
      text: json['text'],
      author: json['author'],
      category: json['category'],
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