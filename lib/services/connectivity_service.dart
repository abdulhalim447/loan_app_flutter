import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // Instance of Connectivity
  final Connectivity _connectivity = Connectivity();

  // Controller for the connectivity status stream
  final _connectivityStreamController = StreamController<bool>.broadcast();

  // Stream of connectivity status (true = connected, false = disconnected)
  Stream<bool> get connectivityStream => _connectivityStreamController.stream;

  // Current connectivity status
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Overlay handling
  OverlayEntry? _overlayEntry;
  bool _isOverlayShown = false;
  Timer? _hideTimer;

  // Initialize the service
  void initialize() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result.first);
    });

    // Check initial connectivity
    checkConnectivity();
  }

  // Check current connectivity
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result.first);
    } catch (e) {
      _connectivityStreamController.add(false);
      _isConnected = false;
    }
  }

  // Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    bool previousStatus = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    // If status changed, notify subscribers
    if (previousStatus != _isConnected) {
      _connectivityStreamController.add(_isConnected);
    }
  }

  // Show no internet dialog
  Future<void> showNoInternetDialog(BuildContext context) async {
    // Only show dialog if not already showing and if there's no connection
    if (!_isConnected) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Internet Connection'),
            content: const Text(
              'Please check your internet connection and try again.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  // Check connectivity again when user tries to reconnect
                  await checkConnectivity();
                  if (_isConnected) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          );
        },
      );
    }
  }

  // Show overlay notification
  void showConnectivityOverlay(BuildContext context, {bool connected = true}) {
    if (_isOverlayShown) {
      _overlayEntry?.remove();
      _hideTimer?.cancel();
      _isOverlayShown = false;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: connected ? Colors.green : Colors.red,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  connected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    connected
                        ? 'Connected to internet'
                        : 'No internet connection',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOverlayShown = true;

    // Hide after 3 seconds
    _hideTimer = Timer(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
      _isOverlayShown = false;
    });
  }

  // Dispose of resources
  void dispose() {
    _connectivityStreamController.close();
    _hideTimer?.cancel();
    _overlayEntry?.remove();
  }
}
