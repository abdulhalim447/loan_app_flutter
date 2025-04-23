import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_bank_loan/screens/card_section/card_screen.dart';
import 'package:world_bank_loan/screens/help_section/help_screen.dart';
import 'package:world_bank_loan/screens/home_section/home_page.dart';
import 'package:world_bank_loan/screens/profile_section/profile_screen.dart';
import 'package:world_bank_loan/services/connectivity_service.dart';
import 'package:world_bank_loan/widgets/connectivity_banner.dart';

// Use a simpler approach for navigation control
class NavigationController {
  static NavigationController? _instance;
  _MainNavigationScreenState? _navigationState;

  NavigationController._();

  static NavigationController get instance {
    _instance ??= NavigationController._();
    return _instance!;
  }

  void registerState(_MainNavigationScreenState state) {
    _navigationState = state;
  }

  void unregisterState(_MainNavigationScreenState state) {
    if (_navigationState == state) {
      _navigationState = null;
    }
  }

  void navigateToHome() {
    _navigationState?.navigateToHome();
  }

  bool get hasRegisteredState => _navigationState != null;
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final Color navigationBarColor = Colors.white;
  late PageController pageController;
  int selectedIndex = 0;
  late List<Widget> _pages;
  bool _isInit = false;
  static const String NAV_INDEX_KEY = 'navigation_index';

  // Add connectivity service
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _connectivitySubscription;

  // Add a key for exit dialog
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize pageController with default value
    pageController = PageController(initialPage: selectedIndex);
    // Register this state with the navigation controller
    NavigationController.instance.registerState(this);
    _loadSavedIndex();

    // Initialize connectivity service
    _connectivityService.initialize();

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        // Show toast notification for connectivity changes
        _connectivityService.showConnectivityOverlay(context,
            connected: isConnected);

        // Show dialog for no internet if needed
        if (!isConnected) {
          _connectivityService.showNoInternetDialog(context);
        }
      }
    });

    // Remove Firebase notification initialization
    // _initializeNotifications();
  }

  @override
  void dispose() {
    // Unregister this state when disposed
    NavigationController.instance.unregisterState(this);
    pageController.dispose();

    // Dispose connectivity subscription
    _connectivitySubscription.cancel();

    super.dispose();
  }

  // Load saved navigation index
  Future<void> _loadSavedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(NAV_INDEX_KEY) ?? 0;

    if (!mounted) return;

    setState(() {
      selectedIndex = savedIndex;
      // Update page controller with the saved index
      pageController.jumpToPage(selectedIndex);
    });
  }

  // Save navigation index
  Future<void> _saveNavigationIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(NAV_INDEX_KEY, index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _pages = [
        const HomeScreen(),
        const CardScreen(),
        const ContactScreen(),
        const ProfileScreen(),
      ];
      _isInit = true;
    }
  }

  Future<void> _onPageChanged(int index) async {
    if (!mounted) return;
    setState(() {
      selectedIndex = index;
    });
    await _saveNavigationIndex(index);
  }

  // Public method to navigate to home screen from anywhere in the app
  void navigateToHome() {
    _navigationHandler(0);
  }

  Future<void> _navigationHandler(int index) async {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    await _saveNavigationIndex(index);

    try {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuad,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (selectedIndex != 0) {
      // If not on home screen, navigate to home screen
      _navigationHandler(0);
      return false;
    } else {
      // If on home screen, show exit dialog
      return await _showExitConfirmationDialog() ?? false;
    }
  }

  // Show dialog to confirm exit
  Future<bool?> _showExitConfirmationDialog() {
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

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      // Check connectivity when widget is first built
      Future.delayed(Duration.zero, () {
        _connectivityService.checkConnectivity();
      });
      return const Center(child: CircularProgressIndicator());
    }

    final navigationContent = WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
                  _buildNavItem(
                      1, Icons.credit_card_rounded, Icons.credit_card_outlined),
                  _buildNavItem(
                      2, Icons.headset_mic_rounded, Icons.headset_mic_outlined),
                  _buildNavItem(
                      3, Icons.person_rounded, Icons.person_outline_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: ConnectivityBanner(
        child: navigationContent,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData filledIcon, IconData outlinedIcon) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? _getSelectedColor() : Colors.grey.shade600;

    return InkWell(
      onTap: () => _navigationHandler(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: color,
              size: 28,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSelectedColor() {
    switch (selectedIndex) {
      case 0:
        return const Color(0xFF3366FF); // Home - Blue
      case 1:
        return const Color(0xFF4E54C8); // Card - Purple
      case 2:
        return const Color(0xFF11998E); // Support - Teal
      case 3:
        return const Color(0xFF6B73FF); // Profile - Indigo
      default:
        return const Color(0xFF3366FF);
    }
  }
}
