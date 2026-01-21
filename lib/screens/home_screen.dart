import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/quote_provider.dart';
// import '../models/quote_model.dart'; // Unused
import '../services/share_service.dart';
import '../services/voice_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../widgets/quote_image_generator.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  final VoiceService _voiceService = VoiceService();
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    // Load interstitial ad immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adService.loadInterstitialAd();
      if (Provider.of<QuoteProvider>(context, listen: false).currentQuote == null) {
        Provider.of<QuoteProvider>(context, listen: false).fetchNewQuote();
      }
    });
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', 
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
        SnackBar(content: Text("Daily quote scheduled for ${picked.format(context)}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Motivation', style: GoogleFonts.lato()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            },
          ),
          IconButton(
             icon: const Icon(Icons.alarm),
             tooltip: 'Schedule Daily Quote',
             onPressed: () => _pickTime(context),
          )
        ],
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: provider.isLoading
                      ? const CircularProgressIndicator()
                      : provider.currentQuote != null
                          ? Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '"${provider.currentQuote!.text}"',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.merriweather(
                                      fontSize: 26,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "- ${provider.currentQuote!.author}",
                                    style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 48),
                                  // Action Buttons Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          provider.favorites.any((q) => q.text == provider.currentQuote!.text)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                        onPressed: () {
                                          provider.toggleFavorite(provider.currentQuote!);
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      IconButton(
                                        icon: const Icon(Icons.share, size: 32, color: Colors.blue),
                                        onPressed: () {
                                          ShareService().shareQuote(provider.currentQuote!.text, author: provider.currentQuote!.author);
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up, size: 32, color: Colors.green),
                                        onPressed: () {
                                          _voiceService.speakQuote("${provider.currentQuote!.text} by ${provider.currentQuote!.author}");
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  // Feature Buttons Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => QuoteImageGenerator(quote: provider.currentQuote!),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.image),
                                        label: const Text("Image Mode"),
                                      ),
                                      const SizedBox(width: 16),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                           NotificationService().showInstantNotification(
                                             "Daily Motivation",
                                             provider.currentQuote!.text
                                           );
                                        },
                                        icon: const Icon(Icons.notifications_active),
                                        label: const Text("Test Notify"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const Text("Press the button to get a quote!"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          // Show ad first
                          _adService.showInterstitialAd();
                          // Show feedback to user
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Loading interstitial ad...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                          // Fetch quote
                          provider.fetchNewQuote();
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Quote'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (_isAdLoaded)
                SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
            ],
          );
        },
      ),
    );
  }
}
