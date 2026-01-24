import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;           // Category ka naam
  final bool isSelected;        // Selected hai ya nahi
  final VoidCallback onTap;     // Tap karne pe kya hoga
  final IconData? icon;         // Optional icon

  CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),

        decoration: BoxDecoration(
          // Selected hone pe color change
          gradient: isSelected
              ? LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          )
              : null,
          color: isSelected ? null : Colors.grey[800],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[700]!,
            width: 1.5,
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (if provided)
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
              SizedBox(width: 8),
            ],

            // Label text
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}