import 'package:flutter/material.dart';
import 'package:asian_development_bank/screens/splash_screen/splash_screen.dart';
import 'services/connection_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ConnectionService _connectionService = ConnectionService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asian Development Bank',
      home: Builder(
        builder: (BuildContext context) {
          _connectionService.initialize(context);
          return SplashScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF002336),
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFF002336),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00839E),
            foregroundColor: Colors.white,
            shadowColor: Color(0xFF002336),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: Size(120, 48),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}