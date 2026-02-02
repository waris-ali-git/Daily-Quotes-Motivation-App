// Voice features handle karne wala

import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final FlutterTts tts = FlutterTts();
  final SpeechToText speech = SpeechToText();

  VoiceService() {
      _initTts();
  }

  Future<void> _initTts() async {
      await tts.setLanguage('en-US');
      
      // Load saved voice preference
      final prefs = await SharedPreferences.getInstance();
      final isMale = prefs.getBool('isMaleVoice') ?? true; // Default to Male as requested "deep voice"
      await updateVoiceSettings(isMale);
  }

  Future<void> updateVoiceSettings(bool isMale) async {
    // 1. Set Pitch and Rate
    if (isMale) {
      // Deep Male Voice Profile
      await tts.setPitch(0.6); // Very deep
      await tts.setSpeechRate(0.4); // Slower and authoritative
    } else {
      // Female / Normal Profile
      await tts.setPitch(1.0); // Standard pitch
      await tts.setSpeechRate(0.5); // Standard rate
    }

    // 2. Try to find a matching Voice Engine
    try {
      List<dynamic> voices = await tts.getVoices;
      if (voices.isNotEmpty) {
        // Define patterns to search for
        final malePatterns = ['male', 'man', 'david', 'james', 'alex', 'en-us-x-iom-network'];
        final femalePatterns = ['female', 'woman', 'samantha', 'victoria', 'en-us-x-sfg-network'];
        
        final patterns = isMale ? malePatterns : femalePatterns;
        
        dynamic selectedVoice;
        
        // Search for preferred voice
        for (String pattern in patterns) {
           selectedVoice = voices.firstWhere(
            (voice) {
              String name = voice['name'].toString().toLowerCase();
              return name.contains(pattern);
            },
            orElse: () => null,
          );
          if (selectedVoice != null) break;
        }

        // Apply if found
        if (selectedVoice != null) {
          await tts.setVoice({
            "name": selectedVoice['name'],
            "locale": selectedVoice['locale']
          });
          print("Voice set to: ${selectedVoice['name']}");
        }
      }
    } catch (e) {
      print("Error setting voice engine: $e");
    }
    
    // 3. Persist preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMaleVoice', isMale);
  }

  // Quote sunana
  Future<void> speakQuote(String text) async {
    await tts.stop(); // Stop previous if any
    if (text.isNotEmpty) {
      await tts.speak(text);
    }
  }
  
  Future<void> stop() async {
      await tts.stop();
  }
}