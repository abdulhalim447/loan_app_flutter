import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asian_development_bank/screens/home_section/withdraw/withdraw_screen.dart';
import 'package:asian_development_bank/screens/loan_apply_screen/loan_apply_screen.dart';
import 'package:asian_development_bank/screens/personal_information/personal_information.dart';
import 'package:asian_development_bank/slider/home_screen_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';
import '../../services/connection_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String balance = "";
  int loanStatus = 0;
  int status = 0;
  String name = "";
  final ConnectionService _connectionService = ConnectionService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _loadStoredUserData(); // First load cached data
    await _getUserData(); // Then try to fetch fresh data
  }

  Future<void> _loadStoredUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getString('balance') ?? "0";
      name = prefs.getString('name') ?? "No Name";
      loanStatus = prefs.getInt('loanStatus') ?? 0;
      status = prefs.getInt('status') ?? 0;
    });
  }

  Future<void> _getUserData() async {
    // First check internet connection
    bool hasConnection = await _connectionService.checkConnection(context);
    if (!hasConnection) return;

    try {
      String? token = await UserSession.getToken();
      if (token == null) {
        setState(() {
          balance = "0";
          name = "Session expired";
          loanStatus = 0;
          status = 0;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://app.wbli.org/api/index'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String newBalance = data['balance'];
        String newName = data['name'] ?? "No Name";
        int newLoanStatus = data['loan_status'];
        int newStatus = data['status'];

        await saveUserData(newBalance, newName, newLoanStatus, newStatus);
        setState(() {
          balance = newBalance;
          name = newName;
          loanStatus = newLoanStatus;
          status = newStatus;
        });
      }
    } catch (e) {
      // If any error occurs during API call, check internet connection again
      _connectionService.checkConnection(context);
    }
  }

  Future<void> saveUserData(
      String balance, String name, int loanStatus, int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('balance', balance);
    await prefs.setString('name', name);
    await prefs.setInt('loanStatus', loanStatus);
    await prefs.setInt('status', status);
  }

  Future<void> _onRefresh() async {
    await _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF002336),
        title: Text('Asian Development Bank', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: isMobile ? double.infinity : 600,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  BalanceSection(balance: balance, name: name),
                  SliderSection(),
                  LoanApplicationSection(
                    loanStatus: loanStatus.toString(),
                    status: status.toString(),
                  ),
                ],
              ),
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
            colors: [Color(0xFF00839E), Colors.deepOrange],
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
                  'ব্যালেন্স',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  '৳$balance',
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
              Icon(Icons.contact_mail_outlined, size: 54, color: Color(0xFF00839E),),
              SizedBox(height: 8),
              // Condition 1: Loan Status == '0' (No loan yet)
              if (loanStatus == '0') ...[
                // If user is status '0' (Information not submitted)
                if (status == '0') ...[
                  Text(
                    'প্রথমে ব্যাক্তিগত তথ্য দিন.',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
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
                      backgroundColor: Color(0xFF00839E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('ব্যাক্তিগত তথ্য'),
                  ),
                ]
                // If user is status '1' (Information verified)
                else if (status == '1') ...[
                  Text(
                    'আপনার ব্যক্তিগত তথ্য জমা দেওয়া হয়েছে। ঋণের জন্য আবেদন করুন।',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
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
                      backgroundColor: Color(0xFF00839E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('লোনের জন্য আবেদন করুন'),
                  ),
                ]
              ]
              // Condition 2: Loan Status == '1' (Loan application under processing)
              else if (loanStatus == '1') ...[
                Center(
                  child: Text(
                    'আপনার ঋণের আবেদন সম্পন্ন হয়েছে, অনুগ্রহ করে অপেক্ষা করুন। আপনার তথ্য যাচাই করার পর ঋণটি পাস/বাতিল করা হবে।',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal,color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                // No button for loan status '1'
              ]
              // Condition 3: Loan Status == '2' (Loan approved)
              else if (loanStatus == '2') ...[
                Text(
                  'অভিনন্দন, আপনার ঋণ সফলভাবে অনুমোদিত হয়েছে।',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
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
                    backgroundColor: Color(0xFF00839E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('উত্তোলন'),
                ),
              ]
              // Condition 4: Loan Status == '3' (Ongoing loan)
              else if (loanStatus == '3') ...[
                Text(
                  'অভিনন্দন! আপনার ঋণের আবেদন গৃহীত হয়েছে, এখন আপনি আপনার টাকা তুলতে পারবেন।',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal,color: Colors.white),
                ),
                SizedBox(height: 16),
                // No button for ongoing loan status '3'
              ]
              // Default Condition: If loan status is invalid
              else ...[
                Text(
                  'অবৈধ ঋণের অবস্থা।',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
