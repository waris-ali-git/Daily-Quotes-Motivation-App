import 'package:flutter/material.dart';
import '../models/quote_model.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final VoidCallback? onFavorite;    // Heart button dabane pe
  final VoidCallback? onShare;       // Share button pe
  final VoidCallback? onSpeak;       // Speaker button pe

  QuoteCard({
    required this.quote,
    this.onFavorite,
    this.onShare,
    this.onSpeak,
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
          colors: [
            Color(0xFF667eea),  // Purple-blue
            Color(0xFF764ba2),  // Deep purple
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quote Text
          Text(
            '"${widget.quote.text}"',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.5,  // Line spacing
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          // Author Name
          Text(
            '- ${widget.quote.author}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
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
                    ? Colors.red
                    : Colors.white,
              ),

              // Share Button
              _buildActionButton(
                icon: Icons.share,
                onTap: widget.onShare,
                color: Colors.white,
              ),

              // Speaker Button
              _buildActionButton(
                icon: Icons.volume_up,
                onTap: widget.onSpeak,
                color: Colors.white,
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