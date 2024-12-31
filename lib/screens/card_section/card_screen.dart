import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for json decoding

import '../../auth/saved_login/user_session.dart'; // Replace with your actual import path

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  bool isLoading = true;
  String cardHolderName = '';
  String cardNumber = '';
  String validity = '';

  // Function to fetch data from the API
  Future<void> fetchCardData() async {
    String? token = await UserSession.getToken();
    if (token == null) {
      // Handle token error (maybe show a login screen)
      return;
    }

    final response = await http.get(
      Uri.parse("https://wbli.org/api/card"),
      headers: {
        "Authorization": "Bearer $token", // Sending the Bearer token
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Extracting card details from the response
      var card = data['card'][0]; // Assuming the response contains the 'card' array
      setState(() {
        cardHolderName = card['cardHolderName'] ?? 'N/A';
        cardNumber = card['cardNumber'] ?? 'N/A';
        validity = card['validity'] ?? 'N/A';
        isLoading = false; // Stop loading when the data is fetched
      });
    } else {
      // Handle error (e.g., display a message to the user)
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCardData(); // Fetch the data when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    // নির্দিষ্ট স্ক্রীন সাইজের উপর ভিত্তি করে ডিজাইন কনফিগার করা
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Card"),
        centerTitle: true,
      ),
      body: Center( // মূল কনটেন্টকে সেন্টারে রাখা
        child: SingleChildScrollView( // স্ক্রল যোগ করা যাতে ছোট স্ক্রীনে ভালো দেখায়
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? CircularProgressIndicator() // লোডিং ইন্ডিকেটর
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Credit Card with Text Overlay
                Container(
                  height: isMobile ? 200 : 200, // মোবাইলে হাইট কমানো
                  width: isMobile ? double.infinity : 600, // ডেস্কটপে নির্দিষ্ট প্রস্থ
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      // Credit Card Image
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            "assets/images/credit_card.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Card Holder Name
                      Positioned(
                        left: 20,
                        bottom: isMobile ? 55: 65, // মোবাইলে পজিশন সামঞ্জস্য
                        child: Text(
                          "Card Holder:  $cardHolderName",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16, // মোবাইলে ফন্ট সাইজ কমানো
                          ),
                        ),
                      ),
                      // Account Number
                      Positioned(
                        left: 20,
                        bottom: isMobile ? 30 : 65,
                        child: Text(
                          "$cardNumber",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                          ),
                        ),
                      ),
                      // Validity Date
                      Positioned(
                        right: 20,
                        bottom: isMobile ? 40 : 50,
                        child: Text(
                          "Valid Till\n$validity",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 15 : 20),
                // Clock and Calendar Icon
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.red,
                  size: isMobile ? 40 : 60,
                ),
                SizedBox(height: isMobile ? 8 : 10),
                // Bengali Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "It's not time to pay your installments yet!",
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
