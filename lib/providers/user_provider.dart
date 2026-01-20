import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  int _currentStreak = 0;
  int _totalChallengesCompleted = 0;

  int get currentStreak => _currentStreak;
  int get totalChallengesCompleted => _totalChallengesCompleted;

  // Load user stats from storage
  Future<void> loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _totalChallengesCompleted = prefs.getInt('totalChallengesCompleted') ?? 0;
    notifyListeners();
  }

  // Mark a challenge as complete
  Future<void> completeChallenge() async {
    _totalChallengesCompleted++;
    _currentStreak++; // Simple increment logic. In a real app, check dates!

    notifyListeners();
    saveUserStats();
  }

  // Save stats to storage
  Future<void> saveUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('totalChallengesCompleted', _totalChallengesCompleted);
  }

  // Reset streak if user missed a day (Logic to be called on app start)
  void checkStreakValidity() {
    // Add logic here to compare DateTime.now() with lastCompletionDate
    // If difference > 1 day, reset _currentStreak to 0
  }
}