import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // using constant categories
    final categories = AppConstants.quoteCategories;

    return Scaffold(
      backgroundColor: Colors.transparent, // Controlled by parent
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 10),
              child: Text(
                'Browse Categories',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3, // Slightly taller for icon
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final title = categories[index];
                  final icon = AppConstants.categoryIcons[title] ?? Icons.star;
                  return _buildCategoryCard(context, title, icon, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, int index) {
    // Alternating gradients logic from AppConstants
    final gradient = AppConstants.allGradients[index % AppConstants.allGradients.length];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXLarge)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
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
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    // Use existing ApiService method (it already fetches a list)
    final quotes = await _api.getQuotesByCategory(widget.category);
    return quotes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstants.secondaryColor),
        title: Text(
          widget.category,
          style: GoogleFonts.playfairDisplay(color: AppConstants.secondaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
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
          final items = (snapshot.data ?? []).cast();
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No quotes found for ${widget.category}.',
                style: GoogleFonts.lato(color: AppConstants.lightGray),
              ),
            );
          }
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
                final q = items[i];
                final text = (q.text ?? '').toString();
                final author = (q.author ?? '').toString();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                    border: Border.all(color: AppConstants.white.withOpacity(0.06)),
                    boxShadow: AppConstants.cardShadow,
                  ),
                  child: ListTile(
                    title: Text(
                      text,
                      style: GoogleFonts.lato(color: AppConstants.white, height: 1.35),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '- $author',
                        style: GoogleFonts.lato(color: AppConstants.paleGold.withOpacity(0.9)),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
