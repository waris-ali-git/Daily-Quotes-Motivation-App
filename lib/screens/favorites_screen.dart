import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';
import '../models/quote_model.dart';
import '../services/share_service.dart';
import '../widgets/quote_image_generator.dart';
import '../utils/constants.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Local colors removed in favor of AppConstants
  bool _showImageGenerator = false;
  Quote? _selectedQuote;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showImageGenerator,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_showImageGenerator) {
          setState(() {
            _showImageGenerator = false;
            _selectedQuote = null;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor, // Dark background to make cards pop
        appBar: AppBar(
          backgroundColor: AppConstants.backgroundColor,
          iconTheme: IconThemeData(color: AppConstants.secondaryColor),
          title: Text(
            'Your Collection',
            style: AppConstants.heading2Gold,
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Main Content
            Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppConstants.secondaryColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.emptyFavorites,
                    style: AppConstants.bodyLarge.copyWith(color: AppConstants.textSecondary),
                    textAlign: TextAlign.center,
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
                  color: AppConstants.cardColor, // Royal Blue Card
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(color: AppConstants.secondaryColor.withOpacity(0.3), width: 1), // Subtle gold border
                  boxShadow: AppConstants.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Decorative quote icon
                      Icon(Icons.format_quote, color: AppConstants.secondaryColor.withOpacity(0.5), size: 30),

                      const SizedBox(height: 8),

                      Text(
                        quote.text,
                        style: AppConstants.quoteTextStyle.copyWith(fontSize: 20, color: AppConstants.secondaryColor), // Golden Text variation
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "- ${quote.author}",
                              style: AppConstants.authorTextStyle.copyWith(color: AppConstants.textPrimary.withOpacity(0.9)),
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
                                  setState(() {
                                    _selectedQuote = quote;
                                    _showImageGenerator = true;
                                  });
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

            // Blur Filter Overlay
            if (_showImageGenerator)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

            // Quote Image Generator Widget
            if (_showImageGenerator && _selectedQuote != null)
              QuoteImageGenerator(
                quote: _selectedQuote!,
                onClose: () {
                  setState(() {
                    _showImageGenerator = false;
                    _selectedQuote = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}