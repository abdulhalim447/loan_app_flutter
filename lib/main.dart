import 'package:flutter/material.dart';
import 'package:asian_development_bank/screens/splash_screen/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF002336), foregroundColor: Colors.white),
        scaffoldBackgroundColor: Color(0xFF002336),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00839E),
            // Button background color
            foregroundColor: Colors.white,
            // Text color
            shadowColor: Color(0xFF002336),
            // Shadow color
            elevation: 5,
            // Elevation for shadow effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            // Padding
            minimumSize: Size(120, 48), // Minimum button size
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.white), // Set text color
          displayMedium: TextStyle(color: Colors.white), // Set body text color
          displaySmall: TextStyle(color: Colors.white), // Set body text color
        ),
      ),
      home: SplashScreen(),
    );
  }
}

