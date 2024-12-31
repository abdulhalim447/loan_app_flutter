import 'package:flutter/material.dart';
import 'package:world_bank_loan/screens/card_section/card_screen.dart';
import 'package:world_bank_loan/screens/help_section/help_screen.dart';
import 'package:world_bank_loan/screens/home_section/home_page.dart';
import 'package:world_bank_loan/screens/profile_section/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // List of screens for each BottomNavigationBar item
  final List<Widget> _pages = [
    HomeScreen(),
    CardScreen(),
    ContactScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    print("Screen width: $screenWidth"); // স্ক্রিন প্রস্থ দেখুন
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected screen
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : (screenWidth - 600) / 2),
        child: Container(
          width: isMobile ? double.infinity : 600,
          child: BottomNavigationBar(
            backgroundColor: Colors.purple,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet),
                label: 'Card',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.phone),
                label: 'Support',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
