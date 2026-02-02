import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/journal_screen.dart';
import 'providers/quote_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/font_size_provider.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await NotificationService().init();
  
  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  
  // Initialize font size provider
  final fontSizeProvider = FontSizeProvider();
  await fontSizeProvider.loadFontSize();

  // Check Onboarding
  final prefs = await SharedPreferences.getInstance();
  final userName = prefs.getString('user_name');
  final bool showOnboarding = userName == null || userName.isEmpty;
  
  runApp(MyApp(
    themeProvider: themeProvider, 
    fontSizeProvider: fontSizeProvider,
    showOnboarding: showOnboarding,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final FontSizeProvider fontSizeProvider;
  final bool showOnboarding;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.fontSizeProvider,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuoteProvider>(create: (_) => QuoteProvider()),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<FontSizeProvider>.value(value: fontSizeProvider),
      ],
      child: Consumer2<ThemeProvider, FontSizeProvider>(
        builder: (context, themeProvider, fontSizeProvider, child) {
          return MaterialApp(
            title: 'Smart Quotes', // Renamed from Daily Quotes
            builder: (context, child) {
              final double scale = fontSizeProvider.getMultiplier();
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                ),
                child: child!,
              );
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.primaryColor,
                primary: AppConstants.primaryColor,
                secondary: AppConstants.secondaryColor,
                surface: AppConstants.surfaceColor,
                background: AppConstants.backgroundColor,
              ),
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.primaryColor,
                primary: AppConstants.primaryColor,
                secondary: AppConstants.secondaryColor,
                surface: AppConstants.surfaceColor,
                background: AppConstants.backgroundColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0F2027), // Fallback to darkest gradient color
            ),
            themeMode: themeProvider.themeMode,
            home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/categories': (_) => const CategoriesScreen(),
              '/challenge': (_) => const ChallengeScreen(),
              '/journal': (_) => const JournalScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
