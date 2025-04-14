import 'dart:async';
import 'package:flutter/material.dart';
import 'package:world_bank_loan/services/connectivity_service.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _connectivitySubscription;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();

    // Initialize connectivity service
    _connectivityService.initialize();

    // Check initial connectivity
    _updateBannerVisibility(!_connectivityService.isConnected);

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivityService.connectivityStream.listen((isConnected) {
      _updateBannerVisibility(!isConnected);
    });
  }

  void _updateBannerVisibility(bool showBanner) {
    if (mounted) {
      setState(() {
        _showBanner = showBanner;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // No internet connection banner
        if (_showBanner)
          Material(
            color: Colors.red,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No internet connection',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _connectivityService.checkConnectivity();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child:
                          const Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }
}
