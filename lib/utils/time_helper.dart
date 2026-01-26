import 'package:intl/intl.dart';

class TimeHelper {

  // ⏰ ============== TIME OF DAY ==============

  /// Current time period nikalna
  static String getCurrentTimePeriod() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  /// Greeting message based on time
  static String getGreeting() {
    final period = getCurrentTimePeriod();

    switch (period) {
      case 'morning':
        return 'Good Morning! ☀️';
      case 'afternoon':
        return 'Good Afternoon! 🌤️';
      case 'evening':
        return 'Good Evening! 🌅';
      case 'night':
        return 'Good Night! 🌙';
      default:
        return 'Hello! 👋';
    }
  }

  /// Time-based quote category suggest karna
  static String getSuggestedCategory() {
    final period = getCurrentTimePeriod();

    switch (period) {
      case 'morning':
        return 'Motivation';  // Subah motivation chahiye
      case 'afternoon':
        return 'Success';     // Dopahar work focus
      case 'evening':
        return 'Peace';       // Shaam ko relaxation
      case 'night':
        return 'Wisdom';      // Raat ko reflection
      default:
        return 'Inspiration';
    }
  }


  // 📅 ============== DATE HELPERS ==============

  /// Aaj ka date formatted
  static String getTodayDate() {
    return DateFormat('MMMM dd, yyyy').format(DateTime.now());
  }

  /// Date ko readable format mein
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Time ko readable format mein
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Date aur time dono
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  /// Relative time (2 hours ago, yesterday, etc.)
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return formatDate(dateTime);
    }
  }


  // 🔥 ============== STREAK CALCULATIONS ==============

  /// Check karo aaj ka challenge complete hua ya nahi
  static bool isChallengeCompletedToday(DateTime? lastCompletedDate) {
    if (lastCompletedDate == null) return false;

    final today = DateTime.now();
    return lastCompletedDate.year == today.year &&
        lastCompletedDate.month == today.month &&
        lastCompletedDate.day == today.day;
  }

  /// Streak calculate karo
  static int calculateStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    // Sort dates (latest first)
    completionDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (var date in completionDates) {
      DateTime completionDate = DateTime(date.year, date.month, date.day);

      if (completionDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else if (completionDate.isBefore(checkDate)) {
        break; // Streak toot gayi
      }
    }

    return streak;
  }

  /// Streak message based on count
  static String getStreakMessage(int streak) {
    if (streak >= 100) return '👑 Legend status!';
    if (streak >= 30) return '🏆 One month champion!';
    if (streak >= 14) return '⭐ Two weeks amazing!';
    if (streak >= 7) return '🔥 One week strong!';
    if (streak >= 3) return '💪 Keep it up!';
    if (streak >= 1) return '🎯 Great start!';
    return 'Start your journey! 🚀';
  }


  // 🔔 ============== NOTIFICATION TIMING ==============

  /// Should show notification or not
  static bool shouldShowNotification(String period) {
    final hour = DateTime.now().hour;

    if (period == 'morning' && hour == 8) {
      return true;  // Morning 8 AM
    } else if (period == 'evening' && hour == 20) {
      return true;  // Evening 8 PM
    }

    return false;
  }

  /// Next notification time
  static DateTime getNextNotificationTime() {
    final now = DateTime.now();

    if (now.hour < 8) {
      // Next morning 8 AM
      return DateTime(now.year, now.month, now.day, 8, 0);
    } else if (now.hour < 20) {
      // Today evening 8 PM
      return DateTime(now.year, now.month, now.day, 20, 0);
    } else {
      // Tomorrow morning 8 AM
      final tomorrow = now.add(Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0);
    }
  }


  // 📊 ============== ANALYTICS HELPERS ==============

  /// Week number nikalna
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Is date within current week?
  static bool isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    return getWeekNumber(date) == getWeekNumber(now) &&
        date.year == now.year;
  }

  /// Is date within current month?
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }


  // 🎯 ============== DAILY QUOTE LOGIC ==============

  /// Check if user ne aaj quote dekha
  static bool hasSeenQuoteToday(DateTime? lastSeenDate) {
    if (lastSeenDate == null) return false;

    final today = DateTime.now();
    return lastSeenDate.year == today.year &&
        lastSeenDate.month == today.month &&
        lastSeenDate.day == today.day;
  }

  /// Time difference in readable format
  static String getTimeDifference(DateTime from, DateTime to) {
    final difference = to.difference(from);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Just now';
    }
  }
}