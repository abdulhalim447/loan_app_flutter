import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutMeScreen extends StatefulWidget {
  @override
  _AboutMeScreenState createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  late final WebViewController _controller;
  String initialUrl = 'https://www.adb.org/who-we-are/about';

  @override
  void initState() {
    super.initState();
    _loadSavedUrl(); // Load the saved URL from SharedPreferences
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..loadRequest(Uri.parse(initialUrl));
  }

  Future<void> _loadSavedUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('savedWebViewUrl');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        initialUrl = savedUrl; // Use the saved URL if available
      });
    }
  }

  Future<void> _saveCurrentUrl() async {
    String? currentUrl = await _controller.currentUrl();
    if (currentUrl != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedWebViewUrl', currentUrl);
    }
  }

  @override
  void dispose() {
    _saveCurrentUrl(); // Save the current URL when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("আমাদের সম্পর্কে"),
        backgroundColor: Colors.blue,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await _controller.canGoBack()) {
            _controller.goBack(); // Navigate back within the WebView
            return false; // Don't pop the screen
          }
          return true; // Pop the screen
        },
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}

