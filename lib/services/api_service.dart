// Internet se quotes laane ka kaam

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class ApiService {
  final String baseUrl = 'https://zenquotes.io/api';

  // Random quote lana
  Future<Quote> getRandomQuote() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/random'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
           return Quote.fromJson(data[0]);
        }
        throw Exception('API returned empty list');
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quote: $e');
    }
  }

  // Category-wise quotes
  Future<List<Quote>> getQuotesByCategory(String category) async {
    // Note: ZenQuotes free tier is limited. 
    // This is a placeholder structure for when a valid endpoint/key is available.
    // For now, we can fetch random quotes and pretend they are from the category
    // or return a list of random quotes.
    try {
       // Placeholder: Fetch 5 random quotes
       final response = await http.get(Uri.parse('$baseUrl/quotes'));
       if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((json) => Quote.fromJson(json)).toList();
       }
       return [];
    } catch (e) {
      debugPrint('Error fetching category quotes: $e');
      return [];
    }
  }
  // Curated Aesthetic Unsplash Image IDs (High Quality, Portrait)
  // These utilize the Direct Link method which is faster and rate-limit free.
  static final Map<String, List<String>> _aestheticIds = {
    'nature': [
      '1472214103451-9374bd1c798e', // Mountain
      '1470071459604-3b5ec3a7fe05', // Foggy Forest
      '1441974231531-c6227db76b6e', // Sunlight Woods
      '1426604966848-d7adac402bff', // Water/Nature
      '1522202176988-66273c2fd55f', // Planning/Desk
      '1486406146926-c627a92ad1ab', // Skyscrapers
      '1507525428034-b723cf961d3e', // Road trip
      '1552664730-d307ca884978', // Teamwork
      '1434030216411-0b793f4b4173', // Study/Library
      '1474552226712-ac0f0961a954', // Sunset Hands
      '1494774157365-9e04c6720e47', // Cinematic Flowers
    ],
  };

  Future<String> fetchQuoteBackgroundImage(String quoteText, String category) async {
    // 1. Determine Category Key
    String key = 'nature'; // Default
    final String text = quoteText.toLowerCase();
    
    if (text.contains('success') || text.contains('money') || text.contains('work') || category.contains('motivational')) {
      key = 'success';
    } else if (text.contains('love') || text.contains('heart') || text.contains('kind')) {
      key = 'love';
    } else if (text.contains('pain') || text.contains('sad') || text.contains('dark') || text.contains('night')) {
      key = 'dark';
    }

    // 2. Select Random ID from that category
    final List<String> list = _aestheticIds[key] ?? _aestheticIds['nature']!;
    // Add extra randomness by sometimes picking from other lists if generic
    final String selectedId = list[DateTime.now().millisecondsSinceEpoch % list.length];

    // 3. Construct Direct URL
    // fit=crop, w=1080, q=80 ensures mobile optimization
    return 'https://images.unsplash.com/photo-$selectedId?auto=format&fit=crop&w=1080&q=80';
  }
}
