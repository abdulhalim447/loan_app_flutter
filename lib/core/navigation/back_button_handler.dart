import 'package:flutter/material.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';

/// A utility class to handle back button behavior consistently throughout the app
class BackButtonHandler {
  /// Intercepts back button presses to navigate to the main screen instead of exiting
  /// Returns false to prevent the default back navigation
  static Future<bool> handleBackPress(BuildContext context) async {
    // Check if we can pop the current route
    if (Navigator.of(context).canPop()) {
      // If we can pop the current route, let the system handle it
      return true;
    } else {
      // Use the navigation controller to navigate to home instead of exiting
      if (NavigationController.instance.hasRegisteredState) {
        NavigationController.instance.navigateToHome();
        return false; // Prevent default back navigation
      }

      // Fallback - show exit dialog if main navigation isn't available
      final shouldExit = await _showExitConfirmationDialog(context);
      return shouldExit ?? false;
    }
  }

  /// Shows a dialog to confirm exiting the app
  static Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
