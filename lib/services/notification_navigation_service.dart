import 'package:flutter/material.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';
import 'package:world_bank_loan/screens/loan_apply_screen/loan_apply_screen.dart';
import 'package:world_bank_loan/screens/profile_section/profile_screen.dart';
import 'package:world_bank_loan/services/notification_service.dart';

/// Service to handle navigation when a notification is tapped
class NotificationNavigationService {
  // Singleton pattern
  static final NotificationNavigationService _instance =
      NotificationNavigationService._internal();

  // Factory constructor to return the same instance
  factory NotificationNavigationService() {
    return _instance;
  }

  // Internal constructor
  NotificationNavigationService._internal();

  /// Navigate to the appropriate screen based on notification data
  Future<void> navigateBasedOnNotification(Map<String, dynamic> data) async {
    // Get the current navigatorState if available
    final NavigatorState? navigator = navigatorKey.currentState;

    if (navigator == null) {
      debugPrint('Navigator is null, cannot navigate');
      return;
    }

    // Handle different notification types
    final String? notificationType = data['type'] as String?;

    debugPrint('Navigating to type: $notificationType');

    switch (notificationType) {
      case 'loan_approval':
        // Navigate to loan details screen
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
          (route) => false,
        );
        // Then navigate to the specific loan screen
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const LoanApplicationScreen(),
          ),
        );
        break;

      case 'payment_reminder':
        // Navigate to payment screen
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
          (route) => false,
        );
        // You would push to a payment screen here
        break;

      case 'profile_update':
        // Navigate to profile screen
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
          (route) => false,
        );
        // Then navigate to the profile screen
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
        break;

      default:
        // Navigate to home screen by default
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
          (route) => false,
        );
        break;
    }
  }
}
