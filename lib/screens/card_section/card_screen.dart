import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON decoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_bank_loan/screens/card_section/get_withdraw.dart';
import 'package:world_bank_loan/screens/home_section/withdraw/withdraw_screen.dart';
import 'package:flutter/foundation.dart'; // For listEquals

import '../../auth/saved_login/user_session.dart';
import '../../bottom_navigation/MainNavigationScreen.dart';

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
  String userBankName = '';
  String userBankNumber = '';

  String walletBalance = "0";
  String walletLoan = "0";
  int loanStatus = 0;
  int status = 0;
  String name = "";

  String detailsBalance = "";
  String detailsName = "";
  int detailsLoanStatus = 0;
  List<dynamic> withdrawList = [];

  @override
  void initState() {
    super.initState();
    _loadStoredCardData();
    fetchCardData();
    _loadStoredCardData();
    _loadStoredWithdrawData(); // Load withdraw data
    fetchWithdrawData();

    _loadStoredData();
    fetchWithdrawDetails();
  }

  // SharedPreferences থেকে ডাটা রিট্রিভ করার জন্য আলাদা ফাংশন
  Future<void> _loadStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBalance = prefs.getString('balance') ?? "0";
    String storedLoan = prefs.getString('loan') ?? "0";
    setState(() {
      walletBalance = storedBalance;
      walletLoan = storedLoan;
    });
  }

  // API কল এবং ডাটা আপডেট করার ফাংশন
  Future<void> fetchWithdrawDetails() async {
    String? token = await UserSession.getToken();
    if (token == null) {
      print("Token is null. Cannot fetch data.");
      return;
    }

    print("Fetching withdraw details...");

    final response = await http.get(
      Uri.parse("https://app.wbli.org/api/method"), // ✅ API লিংক
      headers: {'Authorization': 'Bearer $token'},
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);
      try {
        final data = json.decode(response.body);

        // API থেকে নতুন ডাটা পাওয়া যাচ্ছে কিনা
        String newBalance = (data['userBankInfo']['balance'] ?? 0).toString();
        String newLoan = (data['userBankInfo']['loanBalance'] ?? 0).toString();

        // SharedPreferences থেকে ডাটা রিট্রিভ করা
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String storedBalance = prefs.getString('balance') ?? "0";
        String storedLoan = prefs.getString('loan') ?? "0";

        // API থেকে পাওয়া ডাটা দিয়ে চেক করুন
        if (newBalance != storedBalance || newLoan != storedLoan) {
          print("Updating local storage with new data...");

          // নতুন ডাটা SharedPreferences এ সেভ করুন
          await prefs.setString('balance', newBalance);
          await prefs.setString('loan', newLoan);

          // UI আপডেট করুন
          setState(() {
            walletBalance = newBalance;
            walletLoan = newLoan;
          });
        } else {
          print("No change in data.");
          // যদি ডাটা না পরিবর্তিত হয়, তাহলে পুরোনো ডাটা SharedPreferences থেকে UI তে সেট করুন
          setState(() {
            walletBalance = storedBalance;
            walletLoan = storedLoan;
          });
        }
      } catch (e) {
        print("Error parsing data: $e");
      }
    } else {
      print("Failed to load data: ${response.statusCode}");
    }
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

  //=====================================================



// Load card data from SharedPreferences
  Future<void> _loadStoredCardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cardHolderName = prefs.getString('cardHolderName') ?? 'Loading...';
      cardNumber = prefs.getString('cardNumber') ?? 'Loading...';
      validity = prefs.getString('validity') ?? 'Loading...';
      userBankName = prefs.getString('userBankName') ?? 'Loading...'; // Load bank name
      userBankNumber = prefs.getString('userBankNumber') ?? 'Loading...'; // Load bank number
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
      Uri.parse("https://app.wbli.org/api/card"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var card = data['cards'][0]; // Assuming the response contains the 'cards' array

      String newCardHolderName = card['cardHolderName'] ?? 'N/A';
      String newCardNumber = card['cardNumber'] ?? 'N/A';
      String newValidity = card['validity'] ?? 'N/A';
      String newUserBankName = data['userBankName'] ?? 'N/A'; // Get bank name
      String newUserBankNumber = data['userBankNumber'] ?? 'N/A'; // Get bank number

      // Save the new data and update the UI if the data has changed
      if (cardHolderName != newCardHolderName ||
          cardNumber != newCardNumber ||
          validity != newValidity ||
          userBankName != newUserBankName ||
          userBankNumber != newUserBankNumber) {
        await _saveCardData(newCardHolderName, newCardNumber, newValidity, newUserBankName, newUserBankNumber);

        setState(() {
          cardHolderName = newCardHolderName;
          cardNumber = newCardNumber;
          validity = newValidity;
          userBankName = newUserBankName; // Update bank name
          userBankNumber = newUserBankNumber; // Update bank number
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

// Save card data to SharedPreferences
  Future<void> _saveCardData(String cardHolderName, String cardNumber, String validity, String userBankName, String userBankNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cardHolderName', cardHolderName);
    await prefs.setString('cardNumber', cardNumber);
    await prefs.setString('validity', validity);
    await prefs.setString('userBankName', userBankName); // Save bank name
    await prefs.setString('userBankNumber', userBankNumber); // Save bank number
  }






  //=====================================================




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
      List<dynamic> withdraws = data['withdraws']; // New data from API

      // Load previously saved data from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedWithdrawData = prefs.getString('withdrawData');
      List<dynamic> storedWithdraws =
          storedWithdrawData != null ? json.decode(storedWithdrawData) : [];

      // Compare new data with old data
      if (storedWithdrawData == null ||
          !listEquals(withdraws, storedWithdraws)) {
        // Save new data if different or no old data exists
        await prefs.setString('withdrawData', json.encode(withdraws));

        setState(() {
          withdrawList = withdraws; // Use new data
        });
      } else {
        setState(() {
          withdrawList = storedWithdraws; // Use old data if no change
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

    return WillPopScope(
      onWillPop: () async {
        // যখন ইউজার ব্যাক বাটনে ক্লিক করবে, হোম স্ক্রিনে নেভিগেট হবে
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigationScreen()), // HomeScreen হলো আপনার হোম স্ক্রিন ক্লাস
        );
        return false; // Returning false to prevent the default pop action
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("ওয়ালেট"),
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
                        height: isMobile ? 175 : 175,
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
                                "$userBankNumber",
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
                                "$userBankName",
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
                      BalanceSection(balance: walletBalance, loan: walletLoan),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WithdrawScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              // Set background color to transparent
                              //onPrimary: Colors.blue, // Text color (you can change it to any color you want)
                              shadowColor:
                                  Colors.transparent, // Optional: removes shadow
                            ),
                            child: Text("রিচার্জ"),
                          ),
                          SizedBox(width: 50),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GetWithdraw()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              // Set background color to transparent
                              //onPrimary: Colors.blue, // Text color (set it as needed)
                              shadowColor: Colors
                                  .transparent, // Optional: remove button shadow
                            ),
                            child: Text("উত্তোলন"),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "বিস্তারিত",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 300, // You can adjust the height as needed
                        child: ListView.builder(
                          itemCount: withdrawList.length,
                          itemBuilder: (context, index) {
                            var withdraw = withdrawList[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              elevation: 5,
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "টাকা: ${withdraw['amount']}",
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      withdraw['status'] == 0
                                          ? 'Pending'
                                          : withdraw['status'] == 1
                                              ? 'Accepted'
                                              : 'Rejected',
                                      style: TextStyle(
                                        color: withdraw['status'] == 1
                                            ? Colors.green
                                            : withdraw['status'] == 2
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${withdraw['created_at']}",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    if (withdraw['status'] ==
                                        2) // Only show reason if status is 2
                                      Text(
                                        "${withdraw['reason']}",
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 14),
                                      ),
                                  ],
                                ),
                                //trailing:
                              ),
                            );
                          },
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

// বালা্চে সেচতিওন

class BalanceSection extends StatelessWidget {
  final String balance;
  final String loan;

  BalanceSection({required this.balance, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
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
