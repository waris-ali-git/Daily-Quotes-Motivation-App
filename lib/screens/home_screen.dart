import 'dart:ui';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/quote_provider.dart';
import '../providers/font_size_provider.dart';
import '../services/share_service.dart';
import '../services/voice_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../widgets/quote_image_generator.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/quote_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'categories_screen.dart';
import 'challenge_screen.dart';
import 'journal_screen.dart';

import '../utils/constants.dart';
import '../utils/mood_analyzer.dart';
import '../utils/time_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  final VoiceService _voiceService = VoiceService();
  final AdService _adService = AdService();
  int _quoteCounter = 0;
  static const int _quotesPerAd = AppConstants.adsFrequency;

  bool _showImageGenerator = false;
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  void _handleTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      _adService.showInterstitialAd();
    }
  }

  void _handleNewQuote() {
    _quoteCounter++;
    Provider.of<QuoteProvider>(context, listen: false).fetchNewQuote();

    if (_quoteCounter % _quotesPerAd == 0) {
      _adService.showInterstitialAd();
    }

    _animationController.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    _loadUserName();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adService.loadInterstitialAd();

      final provider = Provider.of<QuoteProvider>(context, listen: false);
      if (provider.currentQuote == null) {
        provider.fetchNewQuote();
      }
      provider.checkStreak();
    });
  }

  String _userName = "";
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Friend";
    });
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.admobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner Ad failed to load: $error');
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _voiceService.stop();
    _bannerAd.dispose();
    _adService.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = _buildHomeTab();
        break;
      case 1:
        currentScreen = const CategoriesScreen();
        break;
      case 2:
        currentScreen = const ChallengeScreen();
        break;
      case 3:
        currentScreen = const JournalScreen();
        break;
      default:
        currentScreen = _buildHomeTab();
    }

    return PopScope(
      canPop: !_showImageGenerator,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_showImageGenerator) {
          setState(() {
            _showImageGenerator = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: _currentIndex == 0 ? _buildHomeAppBar() : null,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(child: currentScreen),
                if (_isAdLoaded)
                  Container(
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd),
                  ),
              ],
            ),
            if (_showImageGenerator)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
            if (_showImageGenerator)
              Consumer<QuoteProvider>(
                builder: (context, provider, child) {
                  return provider.currentQuote != null
                      ? QuoteImageGenerator(
                    quote: provider.currentQuote!,
                    onClose: () {
                      setState(() {
                        _showImageGenerator = false;
                      });
                    },
                  )
                      : Container();
                },
              ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleTabChange,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Row(
        children: [
          // Simplified accent bar with subtle gradient
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)]
                    : AppConstants.pureGoldGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Smart Quotes',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        // Refined streak badge
        Consumer<QuoteProvider>(
          builder: (context, provider, child) {
            return InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(TimeHelper.getStreakMessage(provider.currentStreak)),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : AppConstants.secondaryColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.currentStreak}',
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white : Colors.orange.shade900,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        // Simplified icon buttons
        IconButton(
          icon: Icon(
            Icons.favorite_border_rounded,
            size: 22,
          ),
          tooltip: 'Favorites',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            size: 22,
          ),
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHomeTab() {
    return Consumer2<QuoteProvider, FontSizeProvider>(
      builder: (context, provider, fontSizeProvider, child) {
        if (provider.isLoading) {
          return LoadingWidget(message: "Finding inspiration...");
        }

        bool isOffline = provider.currentQuote?.author == "Offline Mode";
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Mood analysis for quote card
        List<Color> cardColors = AppConstants.deepOceanGradient;
        if (provider.currentQuote != null) {
          final mood = MoodAnalyzer.analyzeMood(provider.currentQuote!.text);
          cardColors = MoodAnalyzer.getMoodColors(mood);
        }

        // Simplified font scaling
        final double scaleFactor = _getFontScale(fontSizeProvider.fontSizeLabel);
        final double quoteSize = 28.0 * scaleFactor;
        final double authorSize = 17.0 * scaleFactor;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? AppConstants.darkModeHomeGradient
                  : AppConstants.lightModeHomeGradient,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),

                    // Refined greeting section
                    Text(
                      TimeHelper.getGreeting(),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.5,
                        height: 1.2,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Simplified name styling - matches the app's typography
                    Text(
                      _userName,
                      style: GoogleFonts.sendFlowers(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.5,
                        height: 1.1,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: isDark
                                ? AppConstants.pureGoldGradient
                                : AppConstants.pureGoldGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your daily dose of inspiration 💫',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Quote Card
                    if (provider.currentQuote != null)
                      QuoteCard(
                        quote: provider.currentQuote!,
                        gradientColors: cardColors,
                        fontSize: quoteSize,
                        authorFontSize: authorSize,
                        onFavorite: () => provider.toggleFavorite(provider.currentQuote!),
                        onShare: () => ShareService().shareQuote(
                          provider.currentQuote!.text,
                          author: provider.currentQuote!.author,
                        ),
                        onSpeak: () => _voiceService.speakQuote(
                          "${provider.currentQuote!.text} by ${provider.currentQuote!.author}",
                        ),
                      )
                    else if (isOffline)
                      ErrorWidget(
                        errorMessage: AppConstants.errorNoInternet,
                        onRetry: _handleNewQuote,
                      ),

                    const SizedBox(height: 28),

                    // Refined action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildPrimaryButton(
                            icon: Icons.auto_awesome_rounded,
                            label: 'New Quote',
                            onPressed: _handleNewQuote,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildSecondaryButton(
                          icon: Icons.image_outlined,
                          onPressed: () {
                            _adService.showInterstitialAd();
                            setState(() {
                              _showImageGenerator = true;
                            });
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Refined quick stats
                    _buildQuickStats(provider, isDark),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Simplified font scale helper
  double _getFontScale(String sizeLabel) {
    switch (sizeLabel) {
      case 'Large':
        return 0.95;
      case 'Medium':
        return 0.80;
      case 'Small':
        return 0.65;
      default:
        return 0.80;
    }
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        // Subtle gradient that doesn't compete with quote card
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF334155),
            const Color(0xFF1E293B),
          ]
              : [
            AppConstants.primaryColor.withOpacity(0.9),
            AppConstants.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppConstants.primaryColor)
                .withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : AppConstants.primaryColor,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(QuoteProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.5)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.auto_stories_rounded,
            label: 'Quotes Read',
            value: '$_quoteCounter',
            color: isDark ? Colors.blue.shade300 : AppConstants.primaryColor,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? Colors.white : Colors.black).withOpacity(0.0),
                  (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                  (isDark ? Colors.white : Colors.black).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          _buildStatItem(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            value: '${provider.favorites.length}',
            color: isDark ? Colors.pink.shade300 : Colors.pink.shade600,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : Colors.black45,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}