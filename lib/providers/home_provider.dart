import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

enum HomeLoadingStatus { initial, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  HomeLoadingStatus _loadingStatus = HomeLoadingStatus.initial;
  String _balance = "0";
  String _name = "No Name";
  int _loanStatus = 0;
  int _userStatus = 0;
  String _errorMessage = '';

  // Add new fields for notifications and profile picture
  int _unreadNotifications = 0;
  int _totalNotifications = 0;
  String? _profilePicUrl;

  // Getters
  HomeLoadingStatus get loadingStatus => _loadingStatus;
  String get balance => _balance;
  String get name => _name;
  int get loanStatus => _loanStatus;
  int get userStatus => _userStatus;
  String get errorMessage => _errorMessage;
  bool get isLoading => _loadingStatus == HomeLoadingStatus.loading;
  bool get hasError => _loadingStatus == HomeLoadingStatus.error;

  // Add getters for new fields
  int get unreadNotifications => _unreadNotifications;
  int get totalNotifications => _totalNotifications;
  String? get profilePicUrl => _profilePicUrl;

  // Get loan status text
  String getLoanStatusText() {
    switch (_loanStatus.toString()) {
      case '0':
        return 'No Active Loan';
      case '1':
        return 'Application Processing';
      case '2':
        return 'Loan Approved';
      case '3':
        return 'Loan Active';
      default:
        return 'Unknown Status';
    }
  }

  // Get loan progress
  double getLoanProgress() {
    switch (_loanStatus.toString()) {
      case '0':
        return _userStatus == 0 ? 0.0 : 0.25;
      case '1':
        return 0.5;
      case '2':
        return 0.75;
      case '3':
        return 1.0;
      default:
        return 0.0;
    }
  }

  // Initialize provider
  Future<void> initialize() async {
    await _loadStoredUserData();
    await fetchUserData();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('balance', _balance);
    await prefs.setString('name', _name);
    await prefs.setInt('loanStatus', _loanStatus);
    await prefs.setInt('status', _userStatus);

    // Save new fields
    await prefs.setInt('unreadNotifications', _unreadNotifications);
    await prefs.setInt('totalNotifications', _totalNotifications);
    if (_profilePicUrl != null) {
      await prefs.setString('profilePicUrl', _profilePicUrl!);
    }
  }

  // Load user data from SharedPreferences
  Future<void> _loadStoredUserData() async {
    _loadingStatus = HomeLoadingStatus.loading;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storedBalance = prefs.getString('balance') ?? "0";
      String storedName = prefs.getString('name') ?? "No Name";
      int storedLoanStatus = prefs.getInt('loanStatus') ?? 0;
      int storedStatus = prefs.getInt('status') ?? 0;

      // Load new fields
      int storedUnreadNotifications = prefs.getInt('unreadNotifications') ?? 0;
      int storedTotalNotifications = prefs.getInt('totalNotifications') ?? 0;
      String? storedProfilePicUrl = prefs.getString('profilePicUrl');

      _balance = storedBalance;
      _name = storedName;
      _loanStatus = storedLoanStatus;
      _userStatus = storedStatus;
      _unreadNotifications = storedUnreadNotifications;
      _totalNotifications = storedTotalNotifications;
      _profilePicUrl = storedProfilePicUrl;

      _loadingStatus = HomeLoadingStatus.loaded;
    } catch (e) {
      _setError('Failed to load stored data: $e');
    }

    notifyListeners();
  }

  // Fetch user data from API
  Future<void> fetchUserData({bool silent = false}) async {
    if (_loadingStatus == HomeLoadingStatus.loading && !silent) return;

    if (!silent) {
      _loadingStatus = HomeLoadingStatus.loading;
      _errorMessage = '';
      notifyListeners();
    }

    try {
      String? token = await UserSession.getToken();
      if (token == null) {
        _setError('User not authenticated');
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.index),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        try {
          String newBalance = data['balance'] ?? "0";
          String newName = data['name'] ?? "No Name";
          int newLoanStatus = data['loan_status'] ?? 0;
          int newStatus = data['status'] ?? 0;

          // Parse new fields
          int newUnreadNotifications = data['unreadNotifications'] ?? 0;
          int newTotalNotifications = data['notifications'] ?? 0;
          String? newProfilePicUrl = data['profile_pic'];

          // Only update if data has changed
          if (_balance != newBalance ||
              _name != newName ||
              _loanStatus != newLoanStatus ||
              _userStatus != newStatus ||
              _unreadNotifications != newUnreadNotifications ||
              _totalNotifications != newTotalNotifications ||
              _profilePicUrl != newProfilePicUrl) {
            _balance = newBalance;
            _name = newName;
            _loanStatus = newLoanStatus;
            _userStatus = newStatus;
            _unreadNotifications = newUnreadNotifications;
            _totalNotifications = newTotalNotifications;
            _profilePicUrl = newProfilePicUrl;

            await _saveUserData();
            notifyListeners();
          }

          _loadingStatus = HomeLoadingStatus.loaded;
        } catch (e) {
          _setError('Failed to parse data: $e');
        }
      } else if (response.statusCode == 401) {
        _setError('Session expired. Please login again');
      } else {
        _setError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Connection error: $e');
    }

    if (!silent) {
      notifyListeners();
    }
  }

  // Reset data
  void reset() {
    _loadingStatus = HomeLoadingStatus.initial;
    _balance = "0";
    _name = "No Name";
    _loanStatus = 0;
    _userStatus = 0;
    _errorMessage = '';
    _unreadNotifications = 0;
    _totalNotifications = 0;
    _profilePicUrl = null;
    notifyListeners();
  }

  // Set error state
  void _setError(String message) {
    _loadingStatus = HomeLoadingStatus.error;
    _errorMessage = message;
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (_unreadNotifications == 0) return;

    try {
      String? token = await UserSession.getToken();
      if (token == null) {
        _setError('User not authenticated');
        return;
      }

      // In a real implementation, you would call the API to mark notifications as read
      // final response = await http.post(
      //   Uri.parse("${ApiEndpoints._baseUrl}/mark-notifications-read"),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // For now, just update the local state
      _unreadNotifications = 0;
      await _saveUserData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark notifications as read: $e');
    }
  }

  // Update unread notification count
  void updateUnreadNotificationCount(int count) {
    if (_unreadNotifications != count) {
      _unreadNotifications = count;
      _saveUserData();
      notifyListeners();
    }
  }
}
