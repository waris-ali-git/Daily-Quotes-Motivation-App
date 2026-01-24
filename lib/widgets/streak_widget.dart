import 'package:flutter/material.dart';

class StreakWidget extends StatefulWidget {
  final int currentStreak;      // Current streak count
  final int longestStreak;      // Best streak ever
  final bool showAnimation;     // Animation chahiye?
  final bool compact;           // Small version for AppBar?

  StreakWidget({
    required this.currentStreak,
    required this.longestStreak,
    this.showAnimation = true,
    this.compact = false,
  });

  @override
  _StreakWidgetState createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // Smooth pulsing
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- COMPACT VIEW (For AppBar) ---
    if (widget.compact) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15), // Glassy effect
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.showAnimation ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    Icons.local_fire_department, 
                    color: Colors.orangeAccent, 
                    size: 20
                  ),
                );
              },
            ),
            SizedBox(width: 6),
            Text(
              '${widget.currentStreak}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87, // Visible on light appbar, change if dark mode
              ),
            ),
          ],
        ),
      );
    }

    // --- FULL VIEW (Large Card) ---
    return Container(
      padding: EdgeInsets.all(20),
      // ... (Rest of original code)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.currentStreak >= 7
              ? [Color(0xFFf093fb), Color(0xFFf5576c)]  // Hot pink for 7+
              : [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          // Fire icon with streak number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                     scale: widget.showAnimation ? _scaleAnimation.value : 1.0,
                     child: Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 40,
                    ),
                  );
                },
              ),
              SizedBox(width: 12),
              Text(
                '${widget.currentStreak}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // Label
          Text(
            widget.currentStreak == 1 ? 'Day Streak' : 'Days Streak',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),

          SizedBox(height: 16),

          // Best streak
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  'Best: ${widget.longestStreak} days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Motivational message
          if (widget.currentStreak >= 7) ...[
            SizedBox(height: 12),
            Text(
              '🎉 You\'re on fire!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}