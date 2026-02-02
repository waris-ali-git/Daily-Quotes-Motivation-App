import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';
import '../models/quote_model.dart';
import '../services/share_service.dart';
import '../widgets/quote_image_generator.dart';
import '../utils/constants.dart';
import '../providers/font_size_provider.dart';
import '../providers/theme_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final isDark = themeProvider.isDarkMode;

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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? AppConstants.darkModeHomeGradient
                : AppConstants.lightModeHomeGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: AppConstants.paleGold,
            ),
            title: Text(
              'Your Collection',
              style: GoogleFonts.inter(
                color: AppConstants.white,
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
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
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstants.richGold.withOpacity(0.1),
                              border: Border.all(
                                color: AppConstants.richGold.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.favorite_border_rounded,
                              size: 64,
                              color: AppConstants.richGold.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No favorites yet',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start collecting golden moments!',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: AppConstants.lightGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                    itemCount: provider.favorites.length,
                    itemBuilder: (context, index) {
                      final Quote quote = provider.favorites[index];
                      return _buildQuoteCard(
                        quote,
                        provider,
                        fontSizeProvider,
                        isDark,
                      );
                    },
                  );
                },
              ),

              // Blur Filter Overlay
              if (_showImageGenerator)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
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
      ),
    );
  }

  Widget _buildQuoteCard(
      Quote quote,
      QuoteProvider provider,
      FontSizeProvider fontSizeProvider,
      bool isDark,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        child: Stack(
          children: [
            // Gradient accent on left edge
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppConstants.pureGoldGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote icon
                  Icon(
                    Icons.format_quote_rounded,
                    color: AppConstants.richGold.withOpacity(0.4),
                    size: fontSizeProvider.getScaledSize(32),
                  ),
                  const SizedBox(height: 12),

                  // Quote text
                  Text(
                    quote.text,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: fontSizeProvider.getScaledSize(18),
                      fontWeight: FontWeight.w500,
                      color: AppConstants.white,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    height: 1,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppConstants.softGoldGradient,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          quote.author,
                          style: GoogleFonts.lato(
                            fontSize: fontSizeProvider.getScaledSize(15),
                            color: AppConstants.paleGold,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.image_outlined,
                            tooltip: 'Image',
                            onPressed: () {
                              setState(() {
                                _selectedQuote = quote;
                                _showImageGenerator = true;
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.share_outlined,
                            tooltip: 'Share',
                            onPressed: () {
                              ShareService().shareQuote(
                                quote.text,
                                author: quote.author,
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.favorite,
                            tooltip: 'Remove',
                            color: AppConstants.errorColor,
                            onPressed: () {
                              _showRemoveDialog(quote, provider);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppConstants.lightGray,
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(Quote quote, QuoteProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Remove from favorites?',
          style: GoogleFonts.montserrat(
            color: AppConstants.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This quote will be removed from your collection.',
          style: GoogleFonts.lato(color: AppConstants.lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: AppConstants.lightGray),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.toggleFavorite(quote);
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: GoogleFonts.lato(
                color: AppConstants.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}