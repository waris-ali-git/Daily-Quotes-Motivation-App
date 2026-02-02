import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../models/quote_model.dart';
import '../providers/quote_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const int _initialCount = 6;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final all = AppConstants.quoteCategories;
    final visible = _showAll ? all : all.take(_initialCount).toList();
    final hasMore = all.length > visible.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          iconTheme: const IconThemeData(color: AppConstants.paleGold),
          title: Text(
            'Categories',
            style: GoogleFonts.playfairDisplay(
              color: AppConstants.white,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    color: Colors.white.withOpacity(0.08),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppConstants.pureGoldGradient,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppConstants.goldGlow,
                        ),
                        child: const Icon(
                          Icons.category_rounded,
                          color: AppConstants.deepBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Topics',
                              style: GoogleFonts.montserrat(
                                color: AppConstants.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find quotes that inspire you',
                              style: GoogleFonts.lato(
                                color: AppConstants.lightGray,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Categories Grid
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final title = visible[index];
                      final icon = AppConstants.categoryIcons[title] ?? Icons.star;
                      final stableIndex = all.indexOf(title);
                      return _buildCategoryCard(context, title, icon, stableIndex);
                    },
                  ),
                ),

                // Show More/Less Button
                if (hasMore || _showAll) ...[
                  const SizedBox(height: 12),
                  if (!_showAll) ...[
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppConstants.pureGoldGradient,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.richGold.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _showAll = true),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.grid_view_rounded,
                                  color: AppConstants.deepBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Browse More Categories',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppConstants.deepBlue,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(
                          color: AppConstants.richGold.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _showAll = false),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.expand_less_rounded,
                                  color: AppConstants.richGold,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Show Less',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppConstants.richGold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      String title,
      IconData icon,
      int index,
      ) {
    final accentColor = AppConstants.categoryColors[title] ?? AppConstants.skyBlue;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _CategoryQuotesScreen(category: title),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.3),
                        accentColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    color: AppConstants.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Accent Dot
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Category Quotes Screen
// ============================================================================

class _CategoryQuotesScreen extends StatefulWidget {
  final String category;

  const _CategoryQuotesScreen({required this.category});

  @override
  State<_CategoryQuotesScreen> createState() => _CategoryQuotesScreenState();
}

class _CategoryQuotesScreenState extends State<_CategoryQuotesScreen> {
  final ApiService _api = ApiService();
  late Future<List<Quote>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Quote>> _load() async {
    final quotes = await _api.getQuotesByCategory(widget.category);
    return quotes;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          iconTheme: const IconThemeData(color: AppConstants.paleGold),
          title: Text(
            widget.category,
            style: GoogleFonts.playfairDisplay(
              color: AppConstants.white,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: FutureBuilder<List<Quote>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.richGold,
                  strokeWidth: 3,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppConstants.errorColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.errorApiFailure,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        color: AppConstants.lightGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            final items = snapshot.data ?? const <Quote>[];

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: AppConstants.mediumGray,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No quotes found for ${widget.category}',
                      style: GoogleFonts.lato(
                        color: AppConstants.lightGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Consumer<QuoteProvider>(
              builder: (context, provider, _) {
                return RefreshIndicator(
                  color: AppConstants.richGold,
                  backgroundColor: AppConstants.cardColor,
                  onRefresh: () async {
                    setState(() => _future = _load());
                    await _future;
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final quote = items[i];
                      final isFav = provider.favorites.any((q) => q.text == quote.text);
                      return _buildQuoteCard(quote, isFav, provider);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote, bool isFav, QuoteProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Stack(
          children: [
            // Left accent strip
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFav
                        ? [Colors.redAccent, Colors.red.shade700]
                        : AppConstants.pureGoldGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote icon
                  Icon(
                    Icons.format_quote_rounded,
                    color: AppConstants.richGold.withOpacity(0.4),
                    size: 28,
                  ),

                  const SizedBox(height: 12),

                  // Quote text
                  Text(
                    quote.text,
                    style: GoogleFonts.playfairDisplay(
                      color: AppConstants.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 14),

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

                  // Author and favorite button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quote.author,
                          style: GoogleFonts.lato(
                            color: AppConstants.paleGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            provider.toggleFavorite(quote);
                            final msg = isFav
                                ? AppConstants.successQuoteRemoved
                                : AppConstants.successQuoteSaved;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      isFav ? Icons.heart_broken : Icons.favorite,
                                      color: AppConstants.richGold,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      msg,
                                      style: GoogleFonts.lato(
                                        color: AppConstants.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppConstants.oceanBlue,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border_rounded,
                              color: isFav ? Colors.redAccent : AppConstants.richGold,
                              size: 22,
                            ),
                          ),
                        ),
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
}
