import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON decoding
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/saved_login/user_session.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStoredCardData(); // Load saved data from SharedPreferences
    fetchCardData(); // Fetch data from API
  }

  // Save card data to SharedPreferences
  Future<void> _saveCardData(String cardHolderName, String cardNumber, String validity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cardHolderName', cardHolderName);
    await prefs.setString('cardNumber', cardNumber);
    await prefs.setString('validity', validity);
  }

  // Load card data from SharedPreferences
  Future<void> _loadStoredCardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cardHolderName = prefs.getString('cardHolderName') ?? 'Loading...';
      cardNumber = prefs.getString('cardNumber') ?? 'Loading...';
      validity = prefs.getString('validity') ?? 'Loading...';
      isLoading = false; // Stop loading when data is loaded
    });
  }

  // Fetch card data from API
  Future<void> fetchCardData() async {
    String? token = await UserSession.getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse("https://wbli.org/api/card"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var card = data['card'][0]; // Assuming the response contains the 'card' array

      String newCardHolderName = card['cardHolderName'] ?? 'N/A';
      String newCardNumber = card['cardNumber'] ?? 'N/A';
      String newValidity = card['validity'] ?? 'N/A';

      // Save the new data and update the UI if the data has changed
      if (cardHolderName != newCardHolderName ||
          cardNumber != newCardNumber ||
          validity != newValidity) {
        await _saveCardData(newCardHolderName, newCardNumber, newValidity);

        setState(() {
          cardHolderName = newCardHolderName;
          cardNumber = newCardNumber;
          validity = newValidity;
        });
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Card"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? CircularProgressIndicator()
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: isMobile ? 200 : 200,
                  width: isMobile ? double.infinity : 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            "assets/images/credit_card.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: isMobile ? 55 : 65,
                        child: Text(
                          "Card Holder: $cardHolderName",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: isMobile ? 30 : 45,
                        child: Text(
                          "$cardNumber",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                          ),
                        ),
                      ),
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
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.red,
                  size: isMobile ? 40 : 60,
                ),
                SizedBox(height: isMobile ? 8 : 10),
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
