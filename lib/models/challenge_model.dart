// Daily challenge ka structure

class Challenge {
  final String id;
  final String quoteId;
  final String challengeText;
  final DateTime date;
  bool isCompleted;

  Challenge({
    required this.id,
    required this.quoteId,
    required this.challengeText,
    required this.date,
    this.isCompleted = false,
  });
}