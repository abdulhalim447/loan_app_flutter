import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../auth/saved_login/user_session.dart';


class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  _AboutMeScreenState createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  String aboutText = "About is coming soon";
  bool isLoading = true;

  // Fetch data from the API
  Future<void> fetchAboutData() async {
    // Get the token from UserSession
    String? token = await UserSession.getToken();

    if (token == null) {
      setState(() {
        aboutText = "No token found. Please log in.";
        isLoading = false;
      });
      return;
    }

    // Set up headers with the token
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse("https://app.wbli.org/api/about"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse the response body if successful
        final data = json.decode(response.body);
        setState(() {
          aboutText = data['about'].join(", ");  // Assuming 'about' is a list
          isLoading = false;
        });
      } else {
        setState(() {
          aboutText = "Failed to load data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        aboutText = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAboutData(); // Call the fetch function on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()  // Show loading spinner while fetching
            : Text(aboutText, style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
