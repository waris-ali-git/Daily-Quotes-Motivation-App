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

  // Load Favorites from SharedPreferences (Call this when app starts)
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('favorite_quotes');

    if (favoritesString != null) {
      final List<dynamic> decoded = json.decode(favoritesString);
      _favorites = decoded.map((item) => Quote.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Save Favorites to SharedPreferences
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_favorites.map((q) => q.toJson()).toList());
    await prefs.setString('favorite_quotes', encodedData);
  }
}