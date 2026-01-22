import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quote_provider.dart';
import '../models/quote_model.dart';
import '../services/share_service.dart';
import '../widgets/quote_image_generator.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Define Royal Colors
  final Color _royalBlue = const Color(0xFF0F172A);
  final Color _gold = const Color(0xFFDAC64F);
  final Color _darkBackground = const Color(0xFFFFFFFF); // Very dark blue/black for contrast

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground, // Dark background to make cards pop
      appBar: AppBar(
        backgroundColor: _darkBackground,
        iconTheme: IconThemeData(color: _gold),
        title: Text(
          'Your Collection',
          style: GoogleFonts.playfairDisplay(
            color: _gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: _royalBlue.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "No gems collected yet.",
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              final Quote quote = provider.favorites[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _royalBlue, // Royal Blue Card
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withOpacity(0.3), width: 1), // Subtle gold border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Decorative quote icon
                      Icon(Icons.format_quote, color: _gold.withOpacity(0.5), size: 30),

                      const SizedBox(height: 8),

                      Text(
                        quote.text,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          color: _gold, // Golden Text
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "- ${quote.author}",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9), // White author for readability
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.image, size: 22),
                                color: Colors.white70,
                                tooltip: 'Image Mode',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuoteImageGenerator(quote: quote),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, size: 22),
                                color: Colors.white70,
                                tooltip: 'Share',
                                onPressed: () {
                                  ShareService().shareQuote(quote.text, author: quote.author);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 22),
                                color: Colors.redAccent,
                                tooltip: 'Remove from Favorites',
                                onPressed: () {
                                  provider.toggleFavorite(quote);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}