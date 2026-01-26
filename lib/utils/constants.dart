import 'package:flutter/material.dart';

class AppConstants {

  // 🎨 ============== PRIMARY THEME COLORS ==============

  // Blue Ambient Colors (Main Theme)
  static const Color deepBlue = Color(0xFF0A1128);           // Very dark blue (background)
  static const Color midnightBlue = Color(0xFF001F54);       // Dark blue (cards)
  static const Color oceanBlue = Color(0xFF034078);          // Medium blue (surfaces)
  static const Color skyBlue = Color(0xFF1282A2);            // Bright blue (accents)
  static const Color lightBlue = Color(0xFF5AB9EA);          // Light blue (highlights)

  // Golden Accent Colors
  static const Color richGold = Color(0xFFFFD700);           // Pure gold
  static const Color warmGold = Color(0xFFFDB833);           // Warm gold
  static const Color paleGold = Color(0xFFFEE9A0);           // Soft gold
  static const Color amberGold = Color(0xFFFFB627);          // Amber gold

  // Supporting Colors
  static const Color white = Color(0xFFFFFFFF);              // Pure white
  static const Color softWhite = Color(0xFFF8F9FA);          // Off white
  static const Color lightGray = Color(0xFFCFD8DC);          // Light gray
  static const Color mediumGray = Color(0xFF8D99AE);         // Medium gray
  static const Color darkGray = Color(0xFF4A5568);           // Dark gray


  // 🎨 ============== SEMANTIC COLORS ==============

  // Primary Colors (Blue Ambient)
  static const Color primaryColor = skyBlue;                 // Main brand color
  static const Color primaryDark = oceanBlue;                // Darker shade
  static const Color primaryLight = lightBlue;               // Lighter shade

  // Secondary Colors (Golden)
  static const Color secondaryColor = richGold;              // Accent/CTA
  static const Color secondaryDark = amberGold;              // Darker gold
  static const Color secondaryLight = paleGold;              // Lighter gold

  // Background Colors
  static const Color backgroundColor = deepBlue;             // App background
  static const Color cardColor = midnightBlue;               // Card background
  static const Color surfaceColor = oceanBlue;               // Surface elements

  // Text Colors
  static const Color textPrimary = white;                    // Primary text
  static const Color textSecondary = lightGray;              // Secondary text
  static const Color textTertiary = mediumGray;              // Tertiary text
  static const Color textGold = warmGold;                    // Golden text for emphasis

  // Status Colors
  static const Color successColor = Color(0xFF10B981);      // Green (success)
  static const Color errorColor = Color(0xFFEF4444);        // Red (error)
  static const Color warningColor = amberGold;               // Gold (warning)
  static const Color infoColor = lightBlue;                  // Blue (info)


  // 🌊 ============== BLUE AMBIENT GRADIENTS ==============

  // Deep Ocean (Primary)
  static const List<Color> deepOceanGradient = [
    Color(0xFF001F54),  // Midnight blue
    Color(0xFF034078),  // Ocean blue
  ];
  // Used in: Main app theme, quote cards, app bar

  // Sky Flow (Light & Airy)
  static const List<Color> skyFlowGradient = [
    Color(0xFF1282A2),  // Sky blue
    Color(0xFF5AB9EA),  // Light blue
  ];
  // Used in: Highlights, success states, info cards

  // Midnight Dream (Dark & Mysterious)
  static const List<Color> midnightDreamGradient = [
    Color(0xFF0A1128),  // Deep blue
    Color(0xFF001F54),  // Midnight blue
  ];
  // Used in: Backgrounds, dark mode intensification

  // Azure Depths (Rich Blue)
  static const List<Color> azureDepthsGradient = [
    Color(0xFF034078),  // Ocean blue
    Color(0xFF1282A2),  // Sky blue
  ];
  // Used in: Interactive elements, buttons, categories


  // ✨ ============== GOLDEN ACCENT GRADIENTS ==============

  // Pure Gold (Luxury)
  static const List<Color> pureGoldGradient = [
    Color(0xFFFFD700),  // Rich gold
    Color(0xFFFDB833),  // Warm gold
  ];
  // Used in: Premium features, streak badges, achievements

  // Sunset Gold (Warm & Inviting)
  static const List<Color> sunsetGoldGradient = [
    Color(0xFFFDB833),  // Warm gold
    Color(0xFFFFB627),  // Amber gold
  ];
  // Used in: CTAs, important buttons, highlights

  // Soft Gold (Elegant)
  static const List<Color> softGoldGradient = [
    Color(0xFFFEE9A0),  // Pale gold
    Color(0xFFFDB833),  // Warm gold
  ];
  // Used in: Subtle accents, hover states


  // 🎨 ============== BLUE + GOLD HYBRID GRADIENTS ==============

  // Ocean Treasure (Blue to Gold)
  static const List<Color> oceanTreasureGradient = [
    Color(0xFF1282A2),  // Sky blue
    Color(0xFFFFD700),  // Rich gold
  ];
  // Used in: Special cards, featured quotes, premium UI

  // Golden Waves (Blue-Gold Mix)
  static const List<Color> goldenWavesGradient = [
    Color(0xFF034078),  // Ocean blue
    Color(0xFF1282A2),  // Sky blue
    Color(0xFFFDB833),  // Warm gold
  ];
  // Used in: Complex UI elements (3-color gradient)

  // Starlit Ocean (Dreamy)
  static const List<Color> starlitOceanGradient = [
    Color(0xFF001F54),  // Midnight blue
    Color(0xFF1282A2),  // Sky blue
    Color(0xFFFEE9A0),  // Pale gold
  ];
  // Used in: Share images, wallpapers, artistic elements


  // 📦 ============== GRADIENT COLLECTIONS ==============

  // Main Theme Gradients (Blue Ambient)
  static const List<List<Color>> blueGradients = [
    deepOceanGradient,
    skyFlowGradient,
    midnightDreamGradient,
    azureDepthsGradient,
  ];

  // Accent Gradients (Golden)
  static const List<List<Color>> goldGradients = [
    pureGoldGradient,
    sunsetGoldGradient,
    softGoldGradient,
  ];

  // All Gradients (Complete Collection)
  static const List<List<Color>> allGradients = [
    deepOceanGradient,      // Primary
    oceanTreasureGradient,  // Special
    skyFlowGradient,        // Light
    pureGoldGradient,       // Luxury
    azureDepthsGradient,    // Rich
    sunsetGoldGradient,     // Warm
  ];


  // 📏 ============== SIZES & SPACING ==============

  // Padding & Margins
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;

  // Border Radius
  static const double radiusTiny = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusCircular = 50.0;

  // Icon Sizes
  static const double iconTiny = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  static const double iconXXLarge = 64.0;

  // Elevation/Shadows
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXHigh = 16.0;


  // 📝 ============== TEXT STYLES (Blue + Gold Theme) ==============

  // Quote Text Styles
  static const TextStyle quoteTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    fontFamily: 'Playfair',
    color: white,                    // White text on blue
    height: 1.6,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.5,
  );

  static const TextStyle authorTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: paleGold,                 // Soft gold for author
    letterSpacing: 1.0,
  );

  // Heading Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: white,
    letterSpacing: 0.5,
  );

  static const TextStyle heading1Gold = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: richGold,                 // Golden heading
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: white,
  );

  static const TextStyle heading2Gold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: warmGold,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: lightGray,
  );

  // Body Text Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: softWhite,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: lightGray,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: mediumGray,
  );

  // Button Text Styles
  static const TextStyle buttonTextPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: deepBlue,                 // Dark text on gold button
    letterSpacing: 0.5,
  );

  static const TextStyle buttonTextSecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,                    // White text on blue button
    letterSpacing: 0.5,
  );

  // Special Text Styles
  static const TextStyle accentText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: richGold,                 // Golden accent text
    letterSpacing: 0.8,
  );

  static const TextStyle subtleText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mediumGray,
    fontStyle: FontStyle.italic,
  );


  // 🌐 ============== API & URLS ==============

  static const String quotesApiUrl = 'https://zenquotes.io/api';
  static const String quotesApiRandom = '$quotesApiUrl/random';
  static const String quotesApiToday = '$quotesApiUrl/today';


  // 📂 ============== CATEGORIES (Blue + Gold Theme) ==============

  static const List<String> quoteCategories = [
    'Motivation',
    'Success',
    'Life',
    'Love',
    'Wisdom',
    'Happiness',
    'Inspiration',
    'Strength',
    'Peace',
    'Growth',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Motivation': Icons.bolt,                    // Lightning bolt
    'Success': Icons.emoji_events,               // Trophy
    'Life': Icons.favorite,                      // Heart
    'Love': Icons.favorite_border,               // Heart outline
    'Wisdom': Icons.auto_stories,                // Book
    'Happiness': Icons.sentiment_very_satisfied, // Happy face
    'Inspiration': Icons.stars,                  // Stars
    'Strength': Icons.fitness_center,            // Dumbbell
    'Peace': Icons.spa,                          // Spa/Peace
    'Growth': Icons.trending_up,                 // Growth arrow
  };

  // Category Colors (Blue shades for categories, Gold for selected)
  static const Map<String, Color> categoryColors = {
    'Motivation': skyBlue,
    'Success': lightBlue,
    'Life': oceanBlue,
    'Love': Color(0xFFFF6B9D),     // Pink accent
    'Wisdom': richGold,
    'Happiness': warmGold,
    'Inspiration': paleGold,
    'Strength': skyBlue,
    'Peace': lightBlue,
    'Growth': richGold,
  };


  // ⏰ ============== TIME PERIODS ==============

  static const int morningStart = 5;    // 5 AM
  static const int morningEnd = 12;     // 12 PM
  static const int afternoonEnd = 17;   // 5 PM
  static const int eveningEnd = 21;     // 9 PM


  // 📱 ============== APP STRINGS ==============

  // App Info
  static const String appName = 'Daily Quotes';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Daily Dose of Inspiration';
  static const String appDescription = 'Dive into an ocean of wisdom with golden moments';

  // Error Messages
  static const String errorNoInternet = 'No internet connection.\nPlease check your network.';
  static const String errorApiFailure = 'Failed to load quotes.\nPlease try again.';
  static const String errorGeneric = 'Something went wrong.\nPlease try again later.';

  // Success Messages
  static const String successQuoteSaved = '✨ Quote saved to favorites!';
  static const String successQuoteRemoved = 'Quote removed from favorites.';
  static const String successQuoteShared = '🎉 Quote shared successfully!';
  static const String successChallengeCompleted = '🔥 Challenge completed!';

  // Empty State Messages
  static const String emptyFavorites = 'No favorite quotes yet.\nStart collecting golden moments!';
  static const String emptyCommunity = 'No quotes submitted yet.\nBe the first to share wisdom!';
  static const String emptyJournal = 'No journal entries yet.\nStart your journey of reflection!';

  // Streak Messages (Gold-themed)
  static const Map<int, String> streakMessages = {
    1: '🌟 First step taken!',
    3: '💫 Building momentum!',
    7: '✨ One week of brilliance!',
    14: '🌠 Two weeks shining bright!',
    30: '👑 Gold standard achieved!',
    100: '🏆 Legendary status unlocked!',
  };


  // 🎯 ============== CHALLENGES ==============

  static const Map<String, String> dailyChallenges = {
    'Start before you\'re ready':
    'Begin that one task you\'ve been postponing',

    'Small steps matter':
    'Take one small action towards your goal today',

    'Gratitude changes everything':
    'Write down 3 things you\'re grateful for',

    'Be kind to yourself':
    'Do something nice for yourself today',

    'Connect with someone':
    'Reach out to a friend or family member',

    'Learn something new':
    'Spend 15 minutes learning a new skill',

    'Step outside comfort zone':
    'Try something that scares you a little',

    'Practice mindfulness':
    'Take 5 minutes to meditate or breathe deeply',

    'Help someone':
    'Do a random act of kindness',

    'Reflect on growth':
    'Write how you\'ve grown in the past month',
  };


  // 🎨 ============== SHARE IMAGE SETTINGS ==============

  // Image dimensions
  static const double shareImageWidth = 1080;
  static const double shareImageHeight = 1080;

  // Available backgrounds for share
  static const List<String> shareBackgrounds = [
    'deep_ocean',      // Deep blue
    'ocean_treasure',  // Blue to gold
    'sky_flow',        // Light blue
    'pure_gold',       // Golden
    'starlit_ocean',   // Mixed dreamy
  ];


  // 📊 ============== ANALYTICS ==============

  static const String eventQuoteViewed = 'quote_viewed';
  static const String eventQuoteFavorited = 'quote_favorited';
  static const String eventQuoteShared = 'quote_shared';
  static const String eventChallengeCompleted = 'challenge_completed';
  static const String eventJournalEntry = 'journal_entry_created';
  static const String eventThemeChanged = 'theme_changed';


  // 💰 ============== MONETIZATION ==============

  static const String admobBannerId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String admobInterstitialId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String admobRewardedId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  static const int adsFrequency = 5; // Show ad after every 5 quotes


  // 🔔 ============== NOTIFICATIONS ==============

  static const String notificationChannelId = 'daily_quotes_channel';
  static const String notificationChannelName = 'Daily Quotes';
  static const String notificationChannelDesc = 'Daily motivational quotes';

  static const int notificationMorningHour = 8;    // 8 AM
  static const int notificationEveningHour = 20;   // 8 PM


  // 💾 ============== STORAGE KEYS ==============

  static const String keyFavorites = 'favorites';
  static const String keyStreak = 'current_streak';
  static const String keyLongestStreak = 'longest_streak';
  static const String keyLastChallengeDate = 'last_challenge_date';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLastQuoteDate = 'last_quote_date';
  static const String keyUserPreferredGradient = 'preferred_gradient';


  // 🎁 ============== PREMIUM FEATURES ==============

  static const String premiumProductId = 'premium_monthly';
  static const double premiumPrice = 99.0; // INR

  static const List<String> premiumFeatures = [
    '✨ Ad-free experience',
    '🎨 Exclusive blue & gold themes',
    '🎤 Premium voice options',
    '📊 Advanced analytics dashboard',
    '🔓 Unlimited journal entries',
    '⭐ Priority support & early access',
    '🌊 Custom gradient creator',
    '👑 Golden badge on profile',
  ];


  // 🎨 ============== UI ENHANCEMENTS ==============

  // Glow effects (for golden elements)
  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x40FFD700),  // Semi-transparent gold
      blurRadius: 20,
      spreadRadius: 2,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> blueGlow = [
    BoxShadow(
      color: Color(0x401282A2),  // Semi-transparent blue
      blurRadius: 15,
      spreadRadius: 1,
      offset: Offset(0, 0),
    ),
  ];

  // Card shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}