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
  
  runApp(MyApp(themeProvider: themeProvider, fontSizeProvider: fontSizeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final FontSizeProvider fontSizeProvider;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.fontSizeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuoteProvider>(create: (_) => QuoteProvider()),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<FontSizeProvider>.value(value: fontSizeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Daily Quotes',
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
              scaffoldBackgroundColor: AppConstants.softWhite,
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
              scaffoldBackgroundColor: AppConstants.backgroundColor,
            ),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
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
