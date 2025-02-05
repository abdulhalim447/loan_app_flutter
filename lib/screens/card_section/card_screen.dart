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
  String cardHolderName = 'Loading...';
  String cardNumber = 'Loading...';
  String validity = 'Loading...';
  String userBankName = 'Loading...';
  String userBankNumber = 'Loading...';

  String walletBalance = "0";
  String walletLoan = "0";
  List<dynamic> withdrawList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Combined method for loading all required data
  Future<void> _loadData() async {
    await _loadStoredData();
    await fetchCardData();
    await fetchWithdrawData();
    await fetchWithdrawDetails();
  }

  // SharedPreferences থেকে ডাটা রিট্রিভ করা
  Future<void> _loadStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      walletBalance = prefs.getString('balance') ?? "0";
      walletLoan = prefs.getString('loan') ?? "0";
    });
  }

  // Fetch card data from API
  Future<void> fetchCardData() async {
    String? token = await UserSession.getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse("https://app.wbli.org/api/card"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var card =
          data['cards'][0]; // Assuming the response contains the 'cards' array

      setState(() {
        cardHolderName = card['cardHolderName'] ?? 'N/A';
        cardNumber = card['cardNumber'] ?? 'N/A';
        validity = card['validity'] ?? 'N/A';
        userBankName = data['userBankName'] ?? 'N/A';
        userBankNumber = data['userBankNumber'] ?? 'N/A';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Withdraw data ফেচ করা
  Future<void> fetchWithdrawData() async {
    String? token = await UserSession.getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse("https://app.wbli.org/api/getWithdraws"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        withdrawList = data['withdraws'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Withdraw details ফেচ করা
  Future<void> fetchWithdrawDetails() async {
    String? token = await UserSession.getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse("https://app.wbli.org/api/method"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'balance', data['userBankInfo']['balance'].toString());
      await prefs.setString(
          'loan', data['userBankInfo']['loanBalance'].toString());

      setState(() {
        walletBalance = data['userBankInfo']['balance'].toString();
        walletLoan = data['userBankInfo']['loanBalance'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ওয়ালেট"), centerTitle: true),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Card section
                      _buildCardSection(),
                      SizedBox(height: 20),
                      BalanceSection(balance: walletBalance, loan: walletLoan),
                      SizedBox(height: 20),
                      // Withdraw section
                      _buildWithdrawSection(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      height: 280,
      width: 600,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset("assets/images/credit_card.png",
                  fit: BoxFit.cover),
            ),
          ),
          Positioned(
              left: 20,
              bottom: 65,
              child: Text(userBankNumber,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Positioned(
              left: 20,
              bottom: 45,
              child: Text(userBankName,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Positioned(
              right: 20,
              bottom: 50,
              child: Text("Valid Till\n$validity",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildWithdrawSection() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    return Container(
      width: isMobile ? double.infinity : 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("বিস্তারিত",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: withdrawList.length,
              itemBuilder: (context, index) {
                var withdraw = withdrawList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  elevation: 5,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("টাকা: ${withdraw['amount']}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            withdraw['status'] == 0
                                ? 'Pending'
                                : withdraw['status'] == 1
                                    ? 'Accepted'
                                    : 'Rejected',
                            style: TextStyle(
                                color: withdraw['status'] == 1
                                    ? Colors.green
                                    : Colors.red)),
                      ],
                    ),
                    subtitle: Text("${withdraw['created_at']}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// বালা্চে সেচতিওন

class BalanceSection extends StatelessWidget {
  final String balance;
  final String loan;

  BalanceSection({required this.balance, required this.loan});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Container(
      width: isMobile ? double.infinity : 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFF29ABE2),
      ),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BalanceColumn(label: "ব্যালেন্স (টাকা)", amount: balance),
          BalanceColumn(label: "লোন (টাকা)", amount: loan),
        ],
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
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
