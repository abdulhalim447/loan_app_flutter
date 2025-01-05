import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_bank_loan/screens/home_section/withdraw/withdraw_screen.dart';
import 'package:world_bank_loan/screens/loan_apply_screen/loan_apply_screen.dart';
import 'package:world_bank_loan/screens/personal_information/personal_information.dart';
import 'package:world_bank_loan/slider/home_screen_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../auth/saved_login/user_session.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String balance = "";
  int loanStatus = 0;
  int status = 0;
  String name = "";

  @override
  void initState() {
    super.initState();
    _loadStoredUserData();  // Load user data from SharedPreferences
    _getUserData();         // Call API to fetch updated data
  }

  // ডাটা সেভ করার ফাংশন
  Future<void> saveUserData(String balance, String name, int loanStatus, int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('balance', balance);
    await prefs.setString('name', name);
    await prefs.setInt('loanStatus', loanStatus);
    await prefs.setInt('status', status);
  }

  // ডাটা লোড করার ফাংশন
  Future<void> _loadStoredUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBalance = prefs.getString('balance') ?? "0";
    String? storedName = prefs.getString('name') ?? "No Name";
    int storedLoanStatus = prefs.getInt('loanStatus') ?? 0;
    int storedStatus = prefs.getInt('status') ?? 0;

    setState(() {
      balance = storedBalance;
      name = storedName;
      loanStatus = storedLoanStatus;
      status = storedStatus;
    });
  }

  // API কল এবং ডাটা আপডেট করার ফাংশন
  Future<void> _getUserData() async {
    String? token = await UserSession.getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('https://wbli.org/api/index'),
        headers: {'Authorization': 'Bearer $token'},
      );



      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String newBalance = data['balance'];
        String newName = data['name'] ?? "No Name";
        int newLoanStatus = data['loan_status'];
        int newStatus = data['status'];

        // Only update if data has changed
        if (balance != newBalance || name != newName || loanStatus != newLoanStatus || status != newStatus) {
          await saveUserData(newBalance, newName, newLoanStatus, newStatus);
          setState(() {
            balance = newBalance;
            name = newName;
            loanStatus = newLoanStatus;
            status = newStatus;
          });
        }
      } else {
        // Handle error
        setState(() {
          balance = "0";
          name = "Failed to load data";
          loanStatus = 0;
          status = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout design
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('WORLD BANK DEVELOPMENT', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: isMobile ? double.infinity : 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                BalanceSection(balance: balance, name: name),
                SliderSection(),
                LoanApplicationSection(
                    loanStatus: loanStatus.toString(), status: status.toString()),
                // Convert to string for passing to the widget
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// balance section =============================================
class BalanceSection extends StatelessWidget {
  final String balance;
  final String name;

  BalanceSection({required this.balance, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  '₹ $balance',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            Column(
              children: [
                Icon(Icons.public, size: 48, color: Colors.white),
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => WithdrawScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Withdraw', style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SliderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10), child: HomeBannerSlider()),
    );
  }
}

class LoanApplicationSection extends StatelessWidget {
  final String loanStatus; // loan status (as String)
  final String status; // user status (as String)

  LoanApplicationSection({required this.loanStatus, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.contact_mail_outlined, size: 54),
              SizedBox(height: 8),
              // Condition 1: Loan Status == '0' (No loan yet)
              if (loanStatus == '0') ...[
                // If user is status '0' (Information not submitted)
                if (status == '0') ...[
                  Text(
                    'Submit your personal information first.',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => PersonalInfoScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Personal Information'),
                  ),
                ]
                // If user is status '1' (Information verified)
                else
                  if (status == '1') ...[
                    Text(
                      'Your personal information has been submitted. Apply for a loan.',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => LoanApplicationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Apply For Loan'),
                    ),
                  ]
              ]
              // Condition 2: Loan Status == '1' (Loan application under processing)
              else
                if (loanStatus == '1') ...[
                  Text(
                    'Your loan application has been completed, please wait. The loan will be passed/cancelled after verifying your information.',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  SizedBox(height: 16),
                  // No button for loan status '1'
                ]
                // Condition 3: Loan Status == '2' (Loan approved)
                else
                  if (loanStatus == '2') ...[
                    Text(
                      'Congratulations your loan has been approved successfully.',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => WithdrawScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Withdraw'),
                    ),
                  ]
                  // Condition 4: Loan Status == '3' (Ongoing loan)
                  else
                    if (loanStatus == '3') ...[
                      Text(
                        'You currently have an ongoing loan.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(height: 16),
                      // No button for ongoing loan status '3'
                    ]
                    // Default Condition: If loan status is invalid
                    else
                      ...[
                        Text(
                          'Invalid loan status.',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ]
            ],
          ),
        ),
      ),
    );
  }
}
