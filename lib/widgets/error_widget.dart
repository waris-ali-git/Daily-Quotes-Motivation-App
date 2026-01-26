import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ErrorWidget extends StatelessWidget {
  final String errorMessage;
  final IconData icon;
  final VoidCallback? onRetry;  // Retry button function

  ErrorWidget({
    required this.errorMessage,
    this.icon = Icons.error_outline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppConstants.errorColor,
              ),
            ),

            SizedBox(height: 24),

            // Error message
            Text(
              errorMessage,
              style: AppConstants.bodyMedium.copyWith(color: AppConstants.textSecondary),
              textAlign: TextAlign.center,
            ),

            // Retry button (if provided)
            if (onRetry != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: AppConstants.deepBlue),
                label: Text('Try Again', style: AppConstants.buttonTextPrimary),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor, // Gold button
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specific error widgets

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  NoInternetWidget({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      errorMessage: 'No internet connection.\nPlease check your network.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  EmptyStateWidget({
    required this.message,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}