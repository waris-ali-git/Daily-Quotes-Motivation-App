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

class _ChallengeScreenState extends State<ChallengeScreen> with SingleTickerProviderStateMixin {
  static const String _prefsKeyChallenge = 'daily_challenge';
  static const String _prefsKeyChallengeDate = AppConstants.keyLastChallengeDate;
  static const String _prefsKeyCompleted = 'daily_challenge_completed';
  static const String _prefsKeyStreak = AppConstants.keyStreak;
  static const String _prefsKeyLongestStreak = AppConstants.keyLongestStreak;

  Challenge? _todayChallenge;
  bool _loading = true;
  int _streak = 0;
  int _longest = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadOrCreateTodayChallenge();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    _todayChallenge = challenge;
    setState(() => _loading = false);
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _markCompleted() async {
    if (_todayChallenge == null) return;
    if (_todayChallenge!.isCompleted) return;

    _animationController.forward().then((_) => _animationController.reverse());

    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());

    final lastCompletedIso = prefs.getString('last_challenge_completed_date');
    final lastCompleted = lastCompletedIso != null ? _dateOnly(DateTime.parse(lastCompletedIso)) : null;

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
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: AppConstants.richGold, size: 20),
            const SizedBox(width: 12),
            Text(
              AppConstants.successChallengeCompleted,
              style: GoogleFonts.lato(color: AppConstants.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppConstants.oceanBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getStreakMessage() {
    if (_streak >= 30) return '👑 Legendary';
    if (_streak >= 14) return '⭐ Unstoppable';
    if (_streak >= 7) return '🔥 On Fire';
    if (_streak >= 3) return '💪 Strong';
    if (_streak >= 1) return '✨ Started';
    return 'Begin Today';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark
            ? const LinearGradient(
                colors: AppConstants.darkModeHomeGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Daily Challenge',
            style: GoogleFonts.montserrat(
              color: isDark ? AppConstants.white : AppConstants.deepBlue,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: IconThemeData(color: isDark ? AppConstants.paleGold : AppConstants.darkerGold),
        ),
        body: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppConstants.richGold,
            strokeWidth: 3,
          ),
        )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Streak Display - Prominent
              _buildStreakCard(),

              const SizedBox(height: 24),

              // Today's Challenge Card - Main Focus
              _buildChallengeCard(),

              const SizedBox(height: 24),

              // Stats Row
              _buildStatsRow(),

              const SizedBox(height: 32),

              // Action Button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        gradient: LinearGradient(
          colors: _streak >= 7
              ? [AppConstants.richGold.withOpacity(0.2), AppConstants.amberGold.withOpacity(0.2)]
              : [AppConstants.skyBlue.withOpacity(0.2), AppConstants.oceanBlue.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _streak >= 7
              ? AppConstants.richGold.withOpacity(0.3)
              : AppConstants.lightBlue.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_streak >= 7 ? AppConstants.richGold : AppConstants.skyBlue).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _streak >= 7
                    ? AppConstants.pureGoldGradient
                    : AppConstants.skyFlowGradient,
              ),
              boxShadow: AppConstants.goldGlow,
            ),
            child: Center(
              child: Icon(
                _streak >= 7 ? Icons.local_fire_department : Icons.star_rounded,
                color: AppConstants.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_streak Day Streak',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStreakMessage(),
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: _streak >= 7 ? AppConstants.paleGold : AppConstants.lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    final isCompleted = _todayChallenge?.isCompleted == true;
    // Rely on Theme.of(context).brightness for consistent UI rendering
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        border: Border.all(
          color: isCompleted
              ? AppConstants.richGold.withOpacity(0.4)
              : (isDark ? Colors.white.withOpacity(0.15) : Colors.grey.withOpacity(0.2)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.richGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConstants.richGold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 14,
                      color: AppConstants.warmGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Today',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.warmGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.richGold.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppConstants.richGold,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _todayChallenge?.id ?? 'Challenge',
            style: GoogleFonts.montserrat(
              color: isDark ? AppConstants.white : AppConstants.deepBlue,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              height: 1.3,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _todayChallenge?.description ?? '',
            style: GoogleFonts.lato(
              color: isDark ? AppConstants.lightGray : Colors.black87,
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Current', '$_streak', Icons.trending_up, AppConstants.skyFlowGradient)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Best', '$_longest', Icons.emoji_events_outlined, AppConstants.pureGoldGradient)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, List<Color> gradient) {
    // Rely on Theme.of(context).brightness for consistent UI rendering
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gradient[0], size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.lato(
                  color: isDark ? AppConstants.mediumGray : AppConstants.mediumGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: isDark ? AppConstants.white : AppConstants.deepBlue,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isCompleted = _todayChallenge?.isCompleted == true;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          gradient: isCompleted
              ? LinearGradient(
            colors: [
              AppConstants.mediumGray.withOpacity(0.5),
              AppConstants.darkGray.withOpacity(0.5),
            ],
          )
              : const LinearGradient(
            colors: AppConstants.pureGoldGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: isCompleted
              ? []
              : [
            BoxShadow(
              color: AppConstants.richGold.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCompleted ? null : _markCompleted,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.celebration_outlined,
                    color: isCompleted ? AppConstants.mediumGray : AppConstants.deepBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCompleted ? 'Challenge Completed' : 'Mark as Completed',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? AppConstants.mediumGray : AppConstants.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}