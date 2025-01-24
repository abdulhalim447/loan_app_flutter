import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON decoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_bank_loan/screens/card_section/get_withdraw.dart';
import 'package:world_bank_loan/screens/home_section/withdraw/withdraw_screen.dart';

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
  String balance = "0";
  int loanStatus = 0;
  int status = 0;
  String name = "";
  String loan = "0";

  String detailsBalance = "";
  String detailsName = "";
  int detailsLoanStatus = 0;

  @override
  void initState() {
    super.initState();
    _loadStoredCardData();
    fetchCardData();
    _loadStoredCardData();
    _loadStoredWithdrawData(); // Load withdraw data
    fetchWithdrawData();
  }

  // Save card data to SharedPreferences
  Future<void> _saveCardData(
      String cardHolderName, String cardNumber, String validity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cardHolderName', cardHolderName);
    await prefs.setString('cardNumber', cardNumber);
    await prefs.setString('validity', validity);
  }

  // Load withdraw data from SharedPreferences
  Future<void> _loadStoredWithdrawData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      detailsBalance = prefs.getString('withdrawAmount') ?? '0';
      detailsName = prefs.getString('withdrawReason') ?? 'N/A';
      detailsLoanStatus = prefs.getInt('withdrawStatus') ?? 0;
    });
  }

  // Load card data from SharedPreferences
  Future<void> _loadStoredCardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cardHolderName = prefs.getString('cardHolderName') ?? 'Loading...';
      cardNumber = prefs.getString('cardNumber') ?? 'Loading...';
      validity = prefs.getString('validity') ?? 'Loading...';
      balance = prefs.getString('balance') ?? ''; // Load balance
      loan = prefs.getString('loan') ?? ''; // Load loan
      isLoading = false; // Stop loading when data is loaded
    });
  }

  //============================================================================

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
      Uri.parse("https://app.wbli.org/api/card"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var card =
          data['card'][0]; // Assuming the response contains the 'card' array

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

  //============================================================================

  // Fetch withdraw data from API ==============================================
  Future<void> fetchWithdrawData() async {
    String? token = await UserSession.getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse("https://app.wbli.org/api/getWithdraws"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var withdraw =
          data['withdraws'][0]; // Assuming there's at least one withdraw

      String amount = withdraw['amount'] ?? '0';
      String reason = withdraw['reason'] ?? 'N/A';
      int status = withdraw['status'] ?? 0;

      // Save withdraw data to SharedPreferences
      await _saveWithdrawData(amount, reason, status);

      setState(() {
        detailsBalance = amount;
        detailsName = reason;
        detailsLoanStatus = status;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save withdraw data to SharedPreferences =================================
  Future<void> _saveWithdrawData(
      String amount, String reason, int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('withdrawAmount', amount);
    await prefs.setString('withdrawReason', reason);
    await prefs.setInt('withdrawStatus', status);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Wallet"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: isMobile ? 180 : 180,
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
                    SizedBox(height: isMobile ? 10 : 15),
                    BalanceSection(balance: balance, loan: loan),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WithdrawScreen()));
                          },
                          child: Text("রিচার্জ"),
                        ),
                        SizedBox(width: 50),
                        ElevatedButton(
                          onPressed: () {Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>GetWithdraw()));},
                          child: Text("উত্তোলন"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "ডিটেইলস",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ব্যালেন্স: \$${detailsBalance}",
                            style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            " ${detailsLoanStatus == 0 ? 'Pending' : detailsLoanStatus == 1 ? 'Accepted' : 'Rejected'}",
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: loanStatus == 1
                                  ? Colors.green
                                  : loanStatus == 2
                                      ? Colors.red
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        "কারণ: $detailsName",
                        //  reason  হবে এানে
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class BalanceSection extends StatelessWidget {
  final String balance;
  final String loan;

  BalanceSection({required this.balance, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFF00839E),
        ),
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BalanceColumn(label: "ব্যালেন্স (টাকা)", amount: balance),
            BalanceColumn(label: "লোন (টাকা)", amount: loan),
          ],
        ),
      ),
    );
  }
}

class BalanceColumn extends StatelessWidget {
  final String label;
  final String amount;

  BalanceColumn({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 5),
        Text(
          amount, // Directly show the string value
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
