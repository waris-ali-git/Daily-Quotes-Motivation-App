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

    return Scaffold(
      backgroundColor: AppConstants.softWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.secondaryColor),
        title: Text(
          'Categories',
          style: GoogleFonts.playfairDisplay(
            color: AppConstants.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppConstants.oceanTreasureGradient,
                    ),
                    boxShadow: AppConstants.elevatedShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse Categories',
                        style: GoogleFonts.montserrat(
                          color: AppConstants.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pick a topic and explore inspiring quotes.',
                        style: GoogleFonts.lato(
                          color: AppConstants.white.withValues(alpha: 0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.25,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final title = visible[index];
                      final icon = AppConstants.categoryIcons[title] ?? Icons.star;
                      // Use stable index from the full list for consistent gradients.
                      final stableIndex = all.indexOf(title);
                      return _buildCategoryCard(context, title, icon, stableIndex);
                    },
                  ),
                ),
                if (hasMore) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _showAll = true),
                      icon: const Icon(Icons.grid_view_rounded),
                      label: Text(
                        'Browse More',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor,
                        foregroundColor: AppConstants.deepBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showAll = false),
                      icon: const Icon(Icons.expand_less),
                      label: Text(
                        'Show Less',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.secondaryColor,
                        side: const BorderSide(color: AppConstants.secondaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, int index) {
    // Minimal style: solid card with subtle accent bar + icon color from category
    final accentColor = AppConstants.categoryColors[title] ?? AppConstants.skyBlue;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXLarge)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          color: AppConstants.midnightBlue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _CategoryQuotesScreen(category: title),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thin accent bar
              Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  shadows: [
                    const Shadow(blurRadius: 5, color: Colors.black26, offset: Offset(0, 2))
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    // Use existing ApiService method (it already fetches a list)
    final quotes = await _api.getQuotesByCategory(widget.category);
    return quotes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.softWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.secondaryColor),
        title: Text(
          widget.category,
          style: GoogleFonts.playfairDisplay(color: AppConstants.secondaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Quote>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.secondaryColor));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppConstants.errorApiFailure,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(color: AppConstants.lightGray),
              ),
            );
          }
          final items = snapshot.data ?? const <Quote>[];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No quotes found for ${widget.category}.',
                style: GoogleFonts.lato(color: AppConstants.lightGray),
              ),
            );
          }
          return Consumer<QuoteProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                color: AppConstants.secondaryColor,
                onRefresh: () async {
                  setState(() => _future = _load());
                  await _future;
                },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final quote = items[i];
                      final isFav = provider.favorites.any((q) => q.text == quote.text);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppConstants.midnightBlue,
                          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingMedium,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"${quote.text}"',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '- ${quote.author}',
                                    style: GoogleFonts.lato(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.redAccent : AppConstants.secondaryColor,
                                    ),
                                    tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                                    onPressed: () {
                                      provider.toggleFavorite(quote);
                                      final msg = isFav
                                          ? AppConstants.successQuoteRemoved
                                          : AppConstants.successQuoteSaved;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              );
            },
          );
        },
      ),
    );
  }
}
