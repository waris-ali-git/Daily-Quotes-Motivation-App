import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

class QuoteProvider with ChangeNotifier {
  Quote? _currentQuote;
  List<Quote> _favorites = [];
  bool _isLoading = false;

  Quote? get currentQuote => _currentQuote;
  List<Quote> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Fetch a random quote from ZenQuotes API
  Future<void> fetchNewQuote() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          _currentQuote = Quote.fromJson(data[0]);
        }
      } else {
        // Fallback if API fails
        _currentQuote = Quote(text: "Keep pushing forward.", author: "Offline Mode", id: DateTime.now().millisecondsSinceEpoch.toString());
      }
    } catch (e) {
      _currentQuote = Quote(text: "Believe in yourself.", author: "Offline Mode", id: DateTime.now().millisecondsSinceEpoch.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  // Toggle Favorite Status
  void toggleFavorite(Quote quote) {
    final existingIndex = _favorites.indexWhere((element) => element.text == quote.text);

    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
      quote.isFavorite = false;
    } else {
      quote.isFavorite = true;
      _favorites.add(quote);
    }

    saveFavorites(); // Persist to local storage
    notifyListeners();
  }

  int _currentStreak = 0;
  int _longestStreak = 0;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  // Check and Update Streak Logic
  Future<void> checkStreak() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Key names
    const String lastVisitKey = 'last_visit_date';
    const String streakKey = 'current_streak';
    const String longestKey = 'longest_streak';

    // Load stored values
    String? lastVisitString = prefs.getString(lastVisitKey);
    _currentStreak = prefs.getInt(streakKey) ?? 0;
    _longestStreak = prefs.getInt(longestKey) ?? 0;

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day); // Strip time
    
    if (lastVisitString == null) {
      // First visit ever
      _currentStreak = 1;
      _updateStreakData(prefs, today, _currentStreak);
    } else {
      DateTime lastVisitRaw = DateTime.parse(lastVisitString);
      DateTime lastVisitDate = DateTime(lastVisitRaw.year, lastVisitRaw.month, lastVisitRaw.day);
      
      if (today.isAtSameMomentAs(lastVisitDate)) {
        // Already visited today, do nothing to streak
      } else if (today.difference(lastVisitDate).inDays == 1) {
        // Consecutive day (Yesterday vs Today)
        _currentStreak++;
      } else {
        // Missed a day (or more) - Reset to 1 (Today counts)
        _currentStreak = 1; 
      }
      
      // Update data
      _updateStreakData(prefs, today, _currentStreak);
    }
    
    notifyListeners();
  }

  Future<void> _updateStreakData(SharedPreferences prefs, DateTime today, int streak) async {
    // Update longest streak if needed
    if (streak > _longestStreak) {
      _longestStreak = streak;
      await prefs.setInt('longest_streak', _longestStreak);
    }

    await prefs.setString('last_visit_date', today.toIso8601String());
    await prefs.setInt('current_streak', streak);
  }

  // Load Favorites from SharedPreferences (Call this when app starts)
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('favorite_quotes');

    if (favoritesString != null) {
      final List<dynamic> decoded = json.decode(favoritesString);
      _favorites = decoded.map((item) => Quote.fromJson(item)).toList();
      notifyListeners();
    }
    
    // Load streak initial values for UI before checkStreak potentially updates them
    _currentStreak = prefs.getInt('current_streak') ?? 0;
    _longestStreak = prefs.getInt('longest_streak') ?? 0;
  }

  // Save Favorites to SharedPreferences
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_favorites.map((q) => q.toJson()).toList());
    await prefs.setString('favorite_quotes', encodedData);
  }
}