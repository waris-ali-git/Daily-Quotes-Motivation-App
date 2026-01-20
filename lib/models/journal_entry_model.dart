class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final String mood; // e.g., "Happy", "Sad", "Motivated"

  JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      mood: json['mood'],
    );
  }
}