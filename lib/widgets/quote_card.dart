import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../utils/constants.dart';

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
  });

  @override
  _QuoteCardState createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),

      // Beautiful gradient background
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors ?? AppConstants.deepOceanGradient,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: AppConstants.elevatedShadow,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quote Text
          Text(
            '"${widget.quote.text}"',
            style: AppConstants.quoteTextStyle,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          // Author Name
          Text(
            '- ${widget.quote.author}',
            style: AppConstants.authorTextStyle,
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
                    : AppConstants.white,
              ),

              // Share Button
              _buildActionButton(
                icon: Icons.share,
                onTap: widget.onShare,
                color: AppConstants.white,
              ),

              // Speaker Button
              _buildActionButton(
                icon: Icons.volume_up,
                onTap: widget.onSpeak,
                color: AppConstants.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}