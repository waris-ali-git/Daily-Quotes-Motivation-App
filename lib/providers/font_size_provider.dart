import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider with ChangeNotifier {
  double _fontSize = 16.0; // Default medium
  String _fontSizeLabel = "Medium";

  double get fontSize => _fontSize;
  String get fontSizeLabel => _fontSizeLabel;

  // Font size multipliers
  static const double smallMultiplier = 0.75;  // Was 0.85
  static const double mediumMultiplier = 0.90; // Was 1.0
  static const double largeMultiplier = 1.15;  // Was 1.25

  Future<void> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sizeLabel = prefs.getString('selectedFontSize');
    
    if (sizeLabel != null) {
      _fontSizeLabel = sizeLabel;
      switch (sizeLabel) {
        case "Small":
          _fontSize = 14.0;
          break;
        case "Medium":
          _fontSize = 16.0;
          break;
        case "Large":
          _fontSize = 20.0;
          break;
      }
      notifyListeners();
    }
  }

  Future<void> setFontSize(String sizeLabel) async {
    _fontSizeLabel = sizeLabel;
    switch (sizeLabel) {
      case "Small":
        _fontSize = 14.0;
        break;
      case "Medium":
        _fontSize = 16.0;
        break;
      case "Large":
        _fontSize = 20.0;
        break;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFontSize', sizeLabel);
    notifyListeners();
  }

  double getMultiplier() {
    switch (_fontSizeLabel) {
      case "Small":
        return smallMultiplier;
      case "Medium":
        return mediumMultiplier;
      case "Large":
        return largeMultiplier;
      default:
        return mediumMultiplier;
    }
  }

  double getScaledSize(double baseSize) {
    return baseSize * getMultiplier();
  }
}
