import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quote_provider.dart';
import '../models/quote_model.dart';
import '../services/share_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh favorites when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: GoogleFonts.lato()),
        centerTitle: true,
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                    "No favorites yet!",
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.favorites.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final Quote quote = provider.favorites[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${quote.text}"',
                        style: GoogleFonts.merriweather(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "- ${quote.author}",
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share, size: 20, color: Colors.blue),
                                onPressed: () {
                                   ShareService().shareQuote(quote.text, author: quote.author);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
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
