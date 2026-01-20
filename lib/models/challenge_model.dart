class Challenge {
  final String id;
  final String description; // The challenge text e.g., "Start that one thing..."
  final DateTime date;
  bool isCompleted;

  Challenge({
    required this.id,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}