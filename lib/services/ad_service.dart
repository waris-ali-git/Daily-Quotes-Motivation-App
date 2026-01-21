import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Using test ad ID first to verify it works
  static const String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';
  // Your real ID (switch after testing):
  // static const String _adUnitId = 'ca-app-pub-7545409441931079/6386506338';
  
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  /// Load an interstitial ad
  void loadInterstitialAd() {
    // Don't load if already have one ready
    if (_isAdReady && _interstitialAd != null) {
      debugPrint('AdService: Ad already ready');
      return;
    }
    
    // Dispose old ad
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
    
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('AdService: LOADING AD - $_adUnitId');
    debugPrint('═══════════════════════════════════════════════════');
    
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('═══════════════════════════════════════════════════');
          debugPrint('AdService: ✅✅✅ AD LOADED! ✅✅✅');
          debugPrint('═══════════════════════════════════════════════════');
          _interstitialAd = ad;
          _isAdReady = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('AdService: ✅ AD IS NOW SHOWING!');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdService: Ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isAdReady = false;
              // Load next ad
              Future.delayed(const Duration(seconds: 1), () {
                loadInterstitialAd();
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdService: ❌ Failed to show: ${error.message}');
              ad.dispose();
              _interstitialAd = null;
              _isAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('═══════════════════════════════════════════════════');
          debugPrint('AdService: ❌ FAILED TO LOAD');
          debugPrint('AdService: ${error.message}');
          debugPrint('AdService: Code: ${error.code}');
          debugPrint('═══════════════════════════════════════════════════');
          _interstitialAd = null;
          _isAdReady = false;
        },
      ),
    );
  }

  /// Show the interstitial ad
  void showInterstitialAd() {
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('AdService: showInterstitialAd() CALLED');
    debugPrint('AdService: isAdReady = $_isAdReady');
    debugPrint('═══════════════════════════════════════════════════');
    
    if (_isAdReady && _interstitialAd != null) {
      debugPrint('AdService: ✅ Showing ad NOW!');
      _interstitialAd!.show();
      _isAdReady = false;
    } else {
      debugPrint('AdService: ⚠️ Ad not ready, loading...');
      loadInterstitialAd();
      // Try again after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (_isAdReady && _interstitialAd != null) {
          debugPrint('AdService: Showing ad after load...');
          _interstitialAd!.show();
          _isAdReady = false;
        }
      });
    }
  }

  bool get isAdReady => _isAdReady;

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
  }
}
