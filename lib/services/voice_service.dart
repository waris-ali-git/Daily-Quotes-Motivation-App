// Voice features handle karne wala

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final FlutterTts tts = FlutterTts();
  final SpeechToText speech = SpeechToText();
  bool _isSpeechInitialized = false;

  VoiceService() {
      _initTts();
  }

  Future<void> _initTts() async {
      await tts.setLanguage('en-US');
      await tts.setPitch(1.0);
      await tts.setSpeechRate(0.5);
  }

  // Quote sunana
  Future<void> speakQuote(String text) async {
    await tts.stop(); // Stop previous if any
    await tts.speak(text);
  }
  
  Future<void> stop() async {
      await tts.stop();
  }
}