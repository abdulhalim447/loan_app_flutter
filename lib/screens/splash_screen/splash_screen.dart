import 'package:flutter/material.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';
import '../../auth/SignupScreen.dart';
import '../../auth/saved_login/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    String? token = await UserSession.getToken();
    if (token != null) {
      // If token exists, navigate to MainNavigationScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    } else {
      // If token does not exist, navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          width: screenWidth > 600 ? 600 : screenWidth,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.network(
                  'https://yt3.googleusercontent.com/ytc/AIdro_k0v2FHYr_czhsvCDN6LNxuaWY1c0osMWV2ZOSmsZC8GNk=s900-c-k-c0x00ffffff-no-rj',
                  height: 100,
                  width: 100,
                ),
                const Spacer(),
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
