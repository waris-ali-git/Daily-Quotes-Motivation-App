// Internet se quotes laane ka kaam

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
        throw Exception('Failed to load quote: ${response.statusCode}');
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
      print('Error fetching category quotes: $e');
      return [];
    }
  }
}