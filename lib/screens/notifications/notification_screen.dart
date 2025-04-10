import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:world_bank_loan/core/theme/app_theme.dart';
import 'package:world_bank_loan/providers/home_provider.dart';

// Add imports for API calls
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:world_bank_loan/core/api/api_endpoints.dart';
import 'package:world_bank_loan/auth/saved_login/user_session.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Load real notifications from API
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get the token for authenticated API calls
      final token = await UserSession.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You need to be logged in to view notifications';
        });
        return;
      }

      // Make API call to fetch notifications
      final response = await http.get(
        Uri.parse(ApiEndpoints.notification),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificationsJson = json.decode(response.body);

        setState(() {
          _notifications = notificationsJson
              .map((item) => {
                    'id': item['id'],
                    'title': 'Notification', // API doesn't have title field
                    'message': item['description'],
                    'date': DateTime.parse(item['created_at']),
                    'isRead': item['status'] == 'read',
                  })
              .toList();

          _isLoading = false;
        });

        // Update unread count in the provider
        _updateUnreadCount();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load notifications: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _updateUnreadCount() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final unreadCount = _notifications.where((n) => !n['isRead']).length;
    homeProvider.updateUnreadNotificationCount(unreadCount);
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final token = await UserSession.getToken();
      if (token == null) return;

      // Make API call to mark notification as read
      final response = await http.post(
        Uri.parse(
            'https://wblloanschema.com/api/notifications/$notificationId/status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Update the local notification state
        setState(() {
          final index =
              _notifications.indexWhere((n) => n['id'] == notificationId);
          if (index != -1) {
            _notifications[index]['isRead'] = true;
          }
        });

        // Update unread count
        _updateUnreadCount();
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notification as read')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await UserSession.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get all unread notification IDs
      final unreadIds = _notifications
          .where((n) => !n['isRead'])
          .map((n) => n['id'])
          .toList();

      // Mark each notification as read sequentially
      for (final id in unreadIds) {
        await _markAsRead(id);
      }

      // Update the provider
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.markAllNotificationsAsRead();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark all notifications as read')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.authorityBlue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.authorityBlue,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.authorityBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_notifications.any((n) => !n['isRead']))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all as read',
                style: TextStyle(
                  color: AppTheme.authorityBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingList()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: AppTheme.authorityBlue,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationItem(notification);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final formattedDate = _formatDate(notification['date'] as DateTime);

    return Container(
      color: isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isRead
                ? Colors.grey.withOpacity(0.1)
                : AppTheme.authorityBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForNotification(notification['message']),
            color: isRead ? Colors.grey : AppTheme.authorityBlue,
          ),
        ),
        title: Text(
          _generateNotificationTitle(notification['message']),
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          // Mark as read when tapped
          if (!isRead) {
            _markAsRead(notification['id']);
          }

          // Handle notification tap (e.g., navigate to relevant screen)
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  String _generateNotificationTitle(String message) {
    // Generate a title based on the message content
    if (message.toLowerCase().contains('loan')) {
      return 'Loan Update';
    } else if (message.toLowerCase().contains('payment')) {
      return 'Payment Notification';
    } else if (message.toLowerCase().contains('account')) {
      return 'Account Update';
    } else if (message.toLowerCase().contains('approved')) {
      return 'Application Approved';
    } else if (message.toLowerCase().contains('verify') ||
        message.toLowerCase().contains('verification')) {
      return 'Verification Notice';
    } else {
      return 'Notification';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Add logic to navigate to relevant screen based on notification type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification: ${notification['message']}'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  IconData _getIconForNotification(String message) {
    if (message.toLowerCase().contains('loan')) {
      return Icons.monetization_on_outlined;
    } else if (message.toLowerCase().contains('payment')) {
      return Icons.payment_outlined;
    } else if (message.toLowerCase().contains('verify') ||
        message.toLowerCase().contains('verification')) {
      return Icons.verified_user_outlined;
    } else if (message.toLowerCase().contains('account')) {
      return Icons.account_circle_outlined;
    } else if (message.toLowerCase().contains('approved')) {
      return Icons.check_circle_outline;
    }
    return Icons.notifications_outlined;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.authorityBlue,
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We\'ll notify you when something important happens',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
