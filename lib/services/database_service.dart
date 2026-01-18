// Phone mein data save karne ka kaam

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';

class DatabaseService {
  final String _favoritesKey = 'favorites_list';

  // Save quote to favorites
  Future<void> addToFavorites(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    // Check if already exists
    bool exists = favorites.any((item) {
      final q = Quote.fromJson(json.decode(item));
      return q.id == quote.id;
    });

    if (!exists) {
      // Mark as favorite before saving
      quote.isFavorite = true;
      favorites.add(json.encode(quote.toJson()));
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Get all favorites
  Future<List<Quote>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    return favorites.map((item) {
      return Quote.fromJson(json.decode(item));
    }).toList();
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String quoteId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    favorites.removeWhere((item) {
      final q = Quote.fromJson(json.decode(item));
      return q.id == quoteId;
    });
    
    await prefs.setStringList(_favoritesKey, favorites);
  }
  
  // Check if favorite
  Future<bool> isFavorite(String quoteId) async {
    final favorites = await getFavorites();
    return favorites.any((q) => q.id == quoteId);
  }
}