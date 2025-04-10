import 'dart:async';
import 'package:flutter/material.dart';

/// A custom notification overlay that can be shown on top of the application
/// to display in-app notifications without using external packages.
class CustomNotificationOverlay {
  static OverlayEntry? _currentOverlay;
  static Timer? _autoHideTimer;

  /// Shows a notification overlay
  /// 
  /// [title] - The title of the notification
  /// [message] - The message body of the notification
  /// [duration] - How long the notification should stay visible (defaults to 4 seconds)
  /// [onTap] - Callback when the notification is tapped
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    // Hide any existing notification first
    hide();

    // Create the overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => _NotificationWidget(
        title: title,
        message: message,
        onTap: () {
          hide();
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );

    // Show the overlay
    Overlay.of(context).insert(_currentOverlay!);

    // Set up auto-hide timer
    _autoHideTimer = Timer(duration, () {
      hide();
    });
  }

  /// Hides the currently shown notification, if any
  static void hide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }
}

/// The actual notification widget that is shown in the overlay
class _NotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onTap;

  const _NotificationWidget({
    required this.title,
    required this.message,
    required this.onTap,
  });

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.cyan,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.cyan.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.cyan,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.message,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: widget.onTap,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 