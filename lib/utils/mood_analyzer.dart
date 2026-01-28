import 'package:flutter/material.dart';
import 'constants.dart';

class MoodAnalyzer {

  // 🧠 ============== MOOD KEYWORDS ==============

  static const Map<String, List<String>> moodKeywords = {
    'happy': [
      'happy', 'joy', 'excited', 'great', 'wonderful', 'amazing',
      'fantastic', 'blessed', 'grateful', 'thankful', 'love',
      'excellent', 'awesome', 'delighted', 'cheerful', 'pleased',
    ],

    'sad': [
      'sad', 'down', 'depressed', 'unhappy', 'miserable', 'upset',
      'disappointed', 'heartbroken', 'lonely', 'alone', 'crying',
      'hurt', 'pain', 'sorrow', 'grief', 'lost',
    ],

    'anxious': [
      'anxious', 'worried', 'nervous', 'scared', 'afraid', 'fear',
      'panic', 'stress', 'stressed', 'overwhelmed', 'tense',
      'uneasy', 'concerned', 'uncertain', 'doubt',
    ],

    'angry': [
      'angry', 'mad', 'furious', 'frustrated', 'annoyed', 'irritated',
      'rage', 'bitter', 'resentful', 'hate', 'disgusted',
    ],

    'motivated': [
      'motivated', 'inspired', 'determined', 'focused', 'driven',
      'ambitious', 'energetic', 'ready', 'confident', 'strong',
      'powerful', 'unstoppable',
    ],

    'tired': [
      'tired', 'exhausted', 'weary', 'drained', 'fatigue', 'sleepy',
      'burned out', 'worn out', 'sluggish', 'lazy',
    ],

    'confused': [
      'confused', 'lost', 'uncertain', 'unclear', 'puzzled',
      'bewildered', 'directionless', 'stuck', 'doubt', 'unsure',
    ],

    'peaceful': [
      'peaceful', 'calm', 'relaxed', 'serene', 'tranquil', 'content',
      'satisfied', 'comfortable', 'balanced', 'centered',
    ],
  };


  // 🎯 ============== MOOD DETECTION ==============

  /// Text se mood detect karo
  static String analyzeMood(String text) {
    if (text.trim().isEmpty) return 'neutral';

    // Text ko lowercase mein convert karo
    final lowerText = text.toLowerCase();

    // Har mood ke liye score calculate karo
    Map<String, int> moodScores = {};

    moodKeywords.forEach((mood, keywords) {
      int score = 0;

      for (var keyword in keywords) {
        // Check if keyword exists in text
        if (lowerText.contains(keyword)) {
          score++;

          // Agar multiple times ho to extra points
          final count = _countOccurrences(lowerText, keyword);
          score += (count - 1);
        }
      }

      moodScores[mood] = score;
    });

    // Highest score wala mood return karo
    if (moodScores.values.every((score) => score == 0)) {
      return 'neutral';
    }

    var maxMood = moodScores.entries.reduce(
            (a, b) => a.value > b.value ? a : b
    );

    return maxMood.key;
  }

  /// Word count karna
  static int _countOccurrences(String text, String word) {
    return word.allMatches(text).length;
  }


  // 💭 ============== MOOD-BASED SUGGESTIONS ==============

  /// Mood ke basis pe quote category suggest karo
  static String suggestCategoryForMood(String mood) {
    switch (mood) {
      case 'happy':
        return 'Gratitude';

      case 'sad':
        return 'Strength';

      case 'anxious':
        return 'Peace';

      case 'angry':
        return 'Wisdom';

      case 'motivated':
        return 'Success';

      case 'tired':
        return 'Rest';

      case 'confused':
        return 'Clarity';

      case 'peaceful':
        return 'Happiness';

      default:
        return 'Motivation';
    }
  }

  /// Mood ke basis pe message
  static String getMoodMessage(String mood) {
    switch (mood) {
      case 'happy':
        return 'Wonderful! Keep spreading that positive energy! ✨';

      case 'sad':
        return 'It\'s okay to feel down. This too shall pass. 💙';

      case 'anxious':
        return 'Take a deep breath. You\'ve got this. 🌊';

      case 'angry':
        return 'Let it out, then let it go. Peace awaits. 🕊️';

      case 'motivated':
        return 'Harness that energy! Great things are coming! 🚀';

      case 'tired':
        return 'Rest is productive too. Take care of yourself. 🌙';

      case 'confused':
        return 'Clarity will come. Trust the process. 🧭';

      case 'peaceful':
        return 'Cherish this beautiful moment of calm. ☮️';

      default:
        return 'Thanks for sharing. Here\'s something for you. 🌟';
    }
  }


  // 🎨 ============== MOOD COLORS ==============

  // 🎨 ============== MOOD COLORS ==============

  static const Map<String, List<Color>> moodColors = {
    'happy': AppConstants.pureGoldGradient,
    'sad': AppConstants.azureDepthsGradient,
    'anxious': AppConstants.skyFlowGradient,
    'angry': [AppConstants.errorColor, Color(0xFFB91C1C)], // Red
    'motivated': [AppConstants.successColor, Color(0xFF059669)], // Green
    'tired': [AppConstants.mediumGray, AppConstants.darkGray],
    'confused': [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // Purple (kept for distinction)
    'peaceful': AppConstants.softGoldGradient,
    'neutral': AppConstants.deepOceanGradient,
  };

  /// Mood ke basis pe gradient colors
  static List<Color> getMoodColors(String mood) {
    return moodColors[mood] ?? moodColors['neutral']!;
  }


  // 📊 ============== MOOD ANALYTICS ==============

  /// Multiple moods ka overall trend
  static String getMoodTrend(List<String> recentMoods) {
    if (recentMoods.isEmpty) return 'No data yet';

    // Count each mood
    Map<String, int> moodCount = {};
    for (var mood in recentMoods) {
      moodCount[mood] = (moodCount[mood] ?? 0) + 1;
    }

    // Most common mood (kept for potential future UI)
    final _ = moodCount.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Positive vs negative
    int positiveCount = 0;
    int negativeCount = 0;

    for (var mood in recentMoods) {
      if (['happy', 'motivated', 'peaceful'].contains(mood)) {
        positiveCount++;
      } else if (['sad', 'anxious', 'angry', 'tired'].contains(mood)) {
        negativeCount++;
      }
    }

    if (positiveCount > negativeCount * 1.5) {
      return 'You\'re doing great! Keep it up! 🌟';
    } else if (negativeCount > positiveCount * 1.5) {
      return 'Tough times, but you\'re strong. 💪';
    } else {
      return 'Life has its ups and downs. You\'re balanced! ⚖️';
    }
  }
// 🎯 ============== SENTIMENT SCORE ==============
  /// -1 (very negative) to +1 (very positive)
  static double getSentimentScore(String text) {
    final mood = analyzeMood(text);
    switch (mood) {
      case 'happy':
      case 'motivated':
      case 'peaceful':
        return 0.8;

      case 'sad':
      case 'anxious':
      case 'angry':
      case 'tired':
        return -0.6;

      case 'confused':
        return -0.3;

      default:
        return 0.0;
    }
  }
}