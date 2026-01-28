import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/challenge_model.dart';
import '../utils/constants.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  static const String _prefsKeyChallenge = 'daily_challenge';
  static const String _prefsKeyChallengeDate = AppConstants.keyLastChallengeDate;
  static const String _prefsKeyCompleted = 'daily_challenge_completed';
  static const String _prefsKeyStreak = AppConstants.keyStreak;
  static const String _prefsKeyLongestStreak = AppConstants.keyLongestStreak;

  Challenge? _todayChallenge;
  bool _loading = true;
  int _streak = 0;
  int _longest = 0;

  @override
  void initState() {
    super.initState();
    _loadOrCreateTodayChallenge();
  }

  Future<void> _loadOrCreateTodayChallenge() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();

    final today = _dateOnly(DateTime.now());
    final storedDateIso = prefs.getString(_prefsKeyChallengeDate);
    final storedChallengeJson = prefs.getString(_prefsKeyChallenge);
    final storedCompleted = prefs.getBool(_prefsKeyCompleted) ?? false;

    _streak = prefs.getInt(_prefsKeyStreak) ?? 0;
    _longest = prefs.getInt(_prefsKeyLongestStreak) ?? 0;

    if (storedDateIso != null &&
        storedChallengeJson != null &&
        _dateOnly(DateTime.parse(storedDateIso)).isAtSameMomentAs(today)) {
      final decoded = json.decode(storedChallengeJson) as Map<String, dynamic>;
      _todayChallenge = Challenge.fromJson(decoded)..isCompleted = storedCompleted;
      setState(() => _loading = false);
      return;
    }

    // New day -> pick deterministic challenge for the day
    final entries = AppConstants.dailyChallenges.entries.toList();
    final index = today.millisecondsSinceEpoch % entries.length;
    final picked = entries[index];

    final challenge = Challenge(
      id: picked.key,
      description: picked.value,
      date: today,
      isCompleted: false,
    );

    await prefs.setString(_prefsKeyChallengeDate, today.toIso8601String());
    await prefs.setString(_prefsKeyChallenge, json.encode(challenge.toJson()));
    await prefs.setBool(_prefsKeyCompleted, false);

    // Reset completion for new day (streak handled when user completes).
    _todayChallenge = challenge;
    setState(() => _loading = false);
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _markCompleted() async {
    if (_todayChallenge == null) return;
    if (_todayChallenge!.isCompleted) return;

    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());

    final lastCompletedIso = prefs.getString('last_challenge_completed_date');
    final lastCompleted = lastCompletedIso != null ? _dateOnly(DateTime.parse(lastCompletedIso)) : null;

    // Update streak
    if (lastCompleted == null) {
      _streak = 1;
    } else if (today.difference(lastCompleted).inDays == 1) {
      _streak += 1;
    } else if (today.isAtSameMomentAs(lastCompleted)) {
      // already counted today
    } else {
      _streak = 1;
    }

    if (_streak > _longest) _longest = _streak;

    _todayChallenge!.isCompleted = true;
    await prefs.setBool(_prefsKeyCompleted, true);
    await prefs.setInt(_prefsKeyStreak, _streak);
    await prefs.setInt(_prefsKeyLongestStreak, _longest);
    await prefs.setString('last_challenge_completed_date', today.toIso8601String());

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppConstants.successChallengeCompleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Daily Challenge',
          style: GoogleFonts.playfairDisplay(color: AppConstants.secondaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppConstants.secondaryColor),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.secondaryColor))
          : Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                      gradient: const LinearGradient(
                        colors: AppConstants.oceanTreasureGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: AppConstants.elevatedShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _todayChallenge?.id ?? 'Challenge',
                          style: GoogleFonts.montserrat(
                            color: AppConstants.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _todayChallenge?.description ?? '',
                          style: GoogleFonts.lato(
                            color: AppConstants.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              _todayChallenge?.isCompleted == true ? Icons.check_circle : Icons.circle_outlined,
                              color: AppConstants.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _todayChallenge?.isCompleted == true ? 'Completed' : 'Not completed',
                              style: GoogleFonts.lato(color: AppConstants.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      boxShadow: AppConstants.cardShadow,
                      border: Border.all(color: AppConstants.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatChip(label: 'Streak', value: '$_streak'),
                        _StatChip(label: 'Best', value: '$_longest'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _todayChallenge?.isCompleted == true ? null : _markCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.secondaryColor,
                      foregroundColor: AppConstants.deepBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
                    ),
                    child: Text(
                      _todayChallenge?.isCompleted == true ? 'Completed' : 'Mark as completed',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadOrCreateTodayChallenge,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.secondaryColor,
                      side: const BorderSide(color: AppConstants.secondaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
                    ),
                    child: Text('Refresh', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        gradient: const LinearGradient(colors: AppConstants.deepOceanGradient),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.lato(color: AppConstants.paleGold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.montserrat(color: AppConstants.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
