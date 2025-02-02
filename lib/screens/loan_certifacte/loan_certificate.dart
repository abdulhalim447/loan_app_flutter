import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';

class LoanCertificatePage extends StatefulWidget {
  @override
  _LoanCertificatePageState createState() => _LoanCertificatePageState();
}

class _LoanCertificatePageState extends State<LoanCertificatePage> {
  String name = '';
  String currentDate = '';
  double loanBalance = 0.0;
  String stampUrl = '';
  String signatureUrl = '';
  String time = '';
  String app_icon = '';
  String phone = '';
  String interest = '';
  String installments = '';
  bool hasLoan = false; // Check if loan exists

  @override
  void initState() {
    super.initState();
    updateDate();
    fetchData();
  }


  // save data to local drive
  Future<void> saveDataLocally(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('loanData', json.encode(data));
  }

  Future<Map<String, dynamic>?> getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('loanData');
    if (jsonData != null) {
      return json.decode(jsonData);
    }
    return null;
  }

  // Update Current Date
  void updateDate() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    setState(() {
      currentDate = 'Date: $formattedDate';
    });
  }

  // Fetch Data from API
  Future<void> fetchData() async {
    final String url = 'https://app.wbli.org/api/certificate';

    try {
      // Retrieve token
      String? token = await UserSession.getToken();
      if (token == null) throw Exception('কোনো টোকেন পাওয়া যায়নি। দয়া করে আবার লগইন করুন।.');

      // লোকাল ডাটা চেক করা
      Map<String, dynamic>? localData = await getLocalData();
      if (localData != null) {
        setState(() {
          updateUI(localData);
        });
      }

      // Set up headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // API Call
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // লোকাল ডাটা সেভ করা
        await saveDataLocally(data);

        // আপডেট করা UI
        setState(() {
          updateUI(data);
        });
      } else {
        throw Exception('Failed to fetch data. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

// ডাটা UI তে আপডেট করার জন্য ফাংশন
  void updateUI(Map<String, dynamic> data) {
    if (data['hasLoan'] == true) {
      hasLoan = true;
      name = data['name'];
      loanBalance = double.parse(data['amount'].toString());
      stampUrl = data['stamp'];
      signatureUrl = data['signature'];
      time = data['time'];
      app_icon = data['app_icon'];
      phone = data['phone'];
      interest = data['interest'];
      installments = data['installments'];
    } else {
      hasLoan = false;
    }
  }







  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('লোন সার্টিফিকেট'),
      ),
      body: Center(
        child: Container(
          width: screenWidth > 600 ? 600 : screenWidth,
          child: hasLoan
              ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // IMF Logo
                  Image.asset(
                    'assets/icons/app_logo.png',
                    height: 80,
                  ),
                  SizedBox(height: 10),

                  // Bank Header
                  Text(
                    'Asian Development bank Loan Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'FOR OFFICIAL USE ONLY',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),

                  // Congratulations Text
                  Text(
                    'CONGRATULATIONS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),

                  Stack(
                    children: [
                      // Watermark Image (Positioned lower in the Stack)
                      Positioned(
                        bottom: 1, // Adjust this value to move the image down
                        left: 0,
                        right: 0,
                        child: Opacity(
                          opacity: 0.3, // Set watermark transparency
                          child: Image.asset(
                            // app_icon,
                            "assets/icons/loan_watermark.png",
                            fit: BoxFit.fitWidth, // Adjusts the image width
                            height: 170,
                            color: Color(0xFF00839E),// Adjust the height if needed
                          ),
                        ),
                      ),

                      // Main Content (Text)
                      Padding(
                        padding: const EdgeInsets.all(3.0), // Add padding for better spacing
                        child: Text.rich(
                          TextSpan(
                            text: 'Dear Sir ', // Regular text
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            children: [
                              TextSpan(
                                text: '$name', // Bold name
                                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                              TextSpan(
                                text: ', Your loan has been approved. The Asian development Bank has registered your proposed loan amount of ',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              TextSpan(
                                text: '$loanBalance', // Bold loan amount
                                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                              TextSpan(
                                text:
                                ' tk. for the purpose of evaluating the Poverty Alleviation Microfinance Project for Business Restructuring and Development. Agriculture business global practice, India Asia Region.',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Agriculture business global practice Bangladesh Asia Region.',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 20),

                  // Approved Stamp Image
                  if (stampUrl.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft, // Aligns the image at the top centre
                      child: Image.network(
                        stampUrl,
                        height: 120,
                        color: Color(0xFF00839E),
                      ),
                    ),

                  SizedBox(height: 10),
                  // Approved Stamp Image
                  if (signatureUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Align(
                        alignment: Alignment.centerLeft, // Aligns the image at the top centre
                        child: Image.network(
                          signatureUrl,
                          height: 30,
                          color: Color(0xFF00839E),
                        ),
                      ),
                    ),

                  SizedBox(height: 10),

                  // Date
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Disclaimer
                  Text(
                    'This document has restricted distribution and may be used by recipients only for their official duties. Unauthorized use is prohibited.',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                    textAlign: TextAlign.justify,

                  ),
                ],
              ),
            ),
          )
              : Center(
            child: Text(
              'You do not have any loan application approved.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
