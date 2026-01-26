import 'dart:ui';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/quote_provider.dart';
import '../providers/font_size_provider.dart';
import '../services/share_service.dart';
import '../services/voice_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../widgets/quote_image_generator.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/quote_card.dart';
import '../widgets/streak_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'categories_screen.dart';
// import 'community_screen.dart'; // Placeholder if needed

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

    // Restart animation
    _animationController.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();
    _initBannerAd();

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

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      await NotificationService().scheduleNotification(picked.hour, picked.minute);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Daily quote scheduled for ${picked.format(context)}"),
          backgroundColor: AppConstants.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = _buildHomeTab();
        break;
      case 1:
        currentScreen = const FavoritesScreen();
        break;
      case 2:
        currentScreen = const CategoriesScreen();
        break;
      case 3:
        currentScreen = const Center(child: Text("Community Screen Placeholder"));
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
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppConstants.pureGoldGradient,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Motivation',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        Consumer<QuoteProvider>(
          builder: (context, provider, child) {
            return InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text(TimeHelper.getStreakMessage(provider.currentStreak)),
                     backgroundColor: AppConstants.secondaryColor,
                     duration: const Duration(seconds: 2),
                   ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppConstants.pureGoldGradient,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.currentStreak}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
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

        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Schedule Daily Quote',
          onPressed: () => _pickTime(context),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
        const SizedBox(width: 4),
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

        // --- MOOD ANALYSIS LOGIC ---
        List<Color> cardColors = AppConstants.deepOceanGradient;
        if (provider.currentQuote != null) {
          final mood = MoodAnalyzer.analyzeMood(provider.currentQuote!.text);
          final moodInts = MoodAnalyzer.getMoodColors(mood);
          cardColors = moodInts;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? AppConstants.midnightDreamGradient
                  : AppConstants.skyFlowGradient, // Or a lighter variant for light mode
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),

                    // Greeting Section using TimeHelper
                    Text(
                      TimeHelper.getGreeting(),
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1.1,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: AppConstants.pureGoldGradient,
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s your daily dose of inspiration 💫',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quote Card with DYNAMIC COLORS
                    if (provider.currentQuote != null)
                      QuoteCard(
                        quote: provider.currentQuote!,
                        gradientColors: cardColors,
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

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildPrimaryButton(
                            icon: Icons.auto_awesome_rounded,
                            label: 'New Quote',
                            onPressed: _handleNewQuote,
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Stats
                    _buildQuickStats(provider, isDark),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppConstants.deepOceanGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppConstants.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(QuoteProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.auto_stories_rounded,
            label: 'Quotes Read',
            value: '${_quoteCounter}',
            color: AppConstants.primaryColor,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _buildStatItem(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            value: '${provider.favorites.length}',
            color: AppConstants.errorColor, // Red/Pinkish
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    // Deprecated: using TimeHelper now
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}