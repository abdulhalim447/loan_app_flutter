import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/widgets/custom_notification_overlay.dart';
import 'package:world_bank_loan/services/notification_navigation_service.dart';

// Global key to access the navigator context for showing notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // This will be used to determine if we've already sent the token
  String? _currentToken;

  // API URL for saving FCM token
  final String _apiUrl = 'https://wblloanschema.com/api/save-fcm-token';

  // Navigation service for handling notification taps
  final _navigationService = NotificationNavigationService();

  Future<void> initialize() async {
    // Request permission for notifications
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');

      // Get FCM token
      await _getAndSendToken();

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        _sendTokenToServer(newToken);
      });

      // Handle incoming messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle message when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Check for initial message (app was terminated)
      _checkInitialMessage();
    } else {
      debugPrint('User declined or has not accepted notification permission');
    }
  }

  // Get and send token to server
  Future<void> _getAndSendToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && token != _currentToken) {
        _currentToken = token;
        await _sendTokenToServer(token);
      }
      print('Token: $token');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  // Send FCM token to Laravel backend
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Get auth token from user session
      final userToken = await UserSession.getToken();

      if (userToken == null) {
        debugPrint('User not logged in, cannot send FCM token to server');
        return;
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM token successfully sent to server');
      } else {
        debugPrint(
            'Failed to send FCM token to server. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint('Notification Title: ${message.notification?.title}');
      debugPrint('Notification Body: ${message.notification?.body}');

      // Show custom in-app notification
      _showCustomInAppNotification(
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new notification',
        message.data,
      );
    }
  }

  // Show a custom in-app notification using our overlay
  void _showCustomInAppNotification(
      String title, String body, Map<String, dynamic> data) {
    // Only show if navigator context is available
    if (navigatorKey.currentContext != null) {
      CustomNotificationOverlay.show(
        navigatorKey.currentContext!,
        title: title,
        message: body,
        onTap: () {
          // Handle notification tap
          _navigationService.navigateBasedOnNotification(data);
        },
      );
    } else {
      debugPrint('Cannot show notification: No valid context available');
    }
  }

  // Handle messages when app is opened from a notification while in background
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('App opened from notification while in background');
    _navigateBasedOnNotification(message);
  }

  // Check if the app was opened from a notification when it was terminated
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App opened from notification while terminated');
      _navigateBasedOnNotification(initialMessage);
    }
  }

  // Navigate to appropriate screen based on notification data
  void _navigateBasedOnNotification(RemoteMessage message) {
    final Map<String, dynamic> data = message.data;
    _navigationService.navigateBasedOnNotification(data);
  }

  // You can also add a method to manually check and update the FCM token
  // This can be called when a user logs in or the app starts
  Future<void> refreshAndUpdateToken() async {
    await _getAndSendToken();
  }

  // Method to subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Method to unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // For debugging: Send a test notification (simulated)
  void sendTestNotification() {
    // In this simplified approach, we just simulate receiving a notification
    final fakeMessage = RemoteMessage(
      notification: RemoteNotification(
        title: 'Test Notification',
        body: 'This is a test notification to verify functionality',
      ),
      data: {
        'type': 'test_notification',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Handle it like a real notification
    _handleForegroundMessage(fakeMessage);
  }
}
