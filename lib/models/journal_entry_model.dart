// Journal entry ka structure

class JournalEntry {
  final String id;
  final String text;
  final DateTime date;
  final String mood; // happy, sad, motivated, confused

  JournalEntry({
    required this.id,
    required this.text,
    required this.date,
    required this.mood,
  });
}