import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final VoidCallback? onFavorite;    // Heart button dabane pe
  final VoidCallback? onShare;       // Share button pe
  final VoidCallback? onSpeak;       // Speaker button pe
  final List<Color>? gradientColors; // Custom gradient colors (optional)

  QuoteCard({
    required this.quote,
    this.onFavorite,
    this.onShare,
    this.onSpeak,

    this.gradientColors,
    this.fontSize,
    this.authorFontSize,
  });

  final double? fontSize;
  final double? authorFontSize;

  @override
  _QuoteCardState createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  @override
  Widget build(BuildContext context) {
    // Rely on Theme.of(context).brightness for consistent UI rendering
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = widget.gradientColors ?? AppConstants.deepOceanGradient;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Use ClipRRect to constrain the Blur to the card shape
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Glassy background
              color: isDark 
                  ? Colors.black.withOpacity(0.3) 
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 // Decorative quote icon
                Icon(
                  Icons.format_quote, 
                  color: gradientColors.first.withOpacity(0.8), 
                  size: 40
                ),
                  
                  SizedBox(height: 10),

                  // Quote Text
                  Text(
                    '"${widget.quote.text}"',
                    style: AppConstants.quoteTextStyle.copyWith(
                      color: isDark ? Colors.white : AppConstants.deepBlue,
                      fontSize: widget.fontSize, // Uses custom size if provided, else inherits style default
                      shadows: isDark ? [] : [
                        Shadow(color: Colors.white, blurRadius: 2),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20),

                  // Author Name
                  Text(
                    '- ${widget.quote.author}',
                    style: AppConstants.authorTextStyle.copyWith(
                       color: isDark ? AppConstants.paleGold : AppConstants.darkerGold,
                       fontSize: widget.authorFontSize,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Favorite Button
                      _buildActionButton(
                        icon: widget.quote.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onTap: widget.onFavorite,
                        color: widget.quote.isFavorite
                            ? AppConstants.errorColor
                            : (isDark ? Colors.white : AppConstants.deepBlue),
                        isDark: isDark,
                      ),

                      // Share Button
                      _buildActionButton(
                        icon: Icons.share,
                        onTap: widget.onShare,
                        color: isDark ? Colors.white : AppConstants.deepBlue,
                        isDark: isDark,
                      ),

                      // Speaker Button
                      _buildActionButton(
                        icon: Icons.volume_up,
                        onTap: widget.onSpeak,
                        color: isDark ? Colors.white : AppConstants.deepBlue,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.3),
             width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double borderRadius;

  _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient || oldDelegate.strokeWidth != strokeWidth;
  }
}