import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';
import '../../core/theme/app_theme.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

class LoanCertificatePage extends StatefulWidget {
  const LoanCertificatePage({super.key});

  @override
  _LoanCertificatePageState createState() => _LoanCertificatePageState();
}

class _LoanCertificatePageState extends State<LoanCertificatePage>
    with SingleTickerProviderStateMixin {
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
  bool _isDisposed = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Set status bar icons to white
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    updateDate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    super.dispose();
  }

  // Update Current Date
  void updateDate() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    setState(() {
      currentDate = formattedDate;
    });
  }

  // Fetch Data from API
  Future<void> fetchData() async {
    if (!mounted || _isDisposed) return;

    final String url = ApiEndpoints.certificate;

    try {
      // Retrieve token
      String? token = await UserSession.getToken();
      if (token == null) {
        throw Exception('No token found. Please log in again.');
      }

      // Set up headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // API Call
      final response = await http.get(Uri.parse(url), headers: headers);
      print(response.statusCode);
      print(response.body);

      if (!mounted || _isDisposed) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if loan exists
        if (data['hasLoan'] == true) {
          setState(() {
            hasLoan = true;
            name = data['name'];
            loanBalance = double.parse(data['amount'].toString());
            stampUrl = data['stamp'];
            signatureUrl = data['signature'];
            time = data['time'];
            app_icon = data['app_icon'];
            phone = data['phone'];
            interest = data['interest'];
            installments = data['interest'];
          });

          if (!_isDisposed) {
            _animationController.forward();
          }
        } else {
          setState(() {
            hasLoan = false;
          });

          if (!_isDisposed) {
            _animationController.forward();
          }
        }
      } else {
        throw Exception('Failed to fetch data. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted && !_isDisposed) {
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.authorityBlue,
        centerTitle: true,
        title: Text(
          'Loan Certificate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          // Gradient background - simplified for better performance
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.authorityBlue,
                  AppTheme.backgroundLight,
                ],
              ),
            ),
          ),

          // Content with animations
          SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (hasLoan) {
      return _buildCertificate();
    } else {
      return _buildNoLoanView();
    }
  }

  Widget _buildNoLoanView() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                size: 50,
                color: Colors.amber[400],
              ),
            ),
            SizedBox(height: 24),
            Text(
              "No Active Loan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral800,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "You do not have any loan application approved. Apply for a loan to receive your certificate.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.neutral600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (!mounted || _isDisposed) return;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authorityBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Certificate background with gold trim
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.amber.shade300,
                    width: 4,
                  ),
                ),
                margin: EdgeInsets.all(1),
              ),

              // Certificate content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top decoration
                    _buildCertificateHeader(),

                    SizedBox(height: 12),

                    // Main content with watermark
                    Stack(
                      children: [
                        // Watermark
                        Positioned.fill(
                          child: Center(
                            child: Opacity(
                              opacity: 0.07,
                              child: Image.network(
                                app_icon.isNotEmpty
                                    ? app_icon
                                    : "https://www.clipartmax.com/png/middle/458-4587792_promanity-international-round-world-map-png.png",
                                height: 200,
                              ),
                            ),
                          ),
                        ),

                        // Main content
                        Column(
                          children: [
                            SizedBox(height: 16),

                            // Certificate title
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.authorityBlue.withOpacity(0.9),
                                    AppTheme.trustCyan,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'OFFICIAL LOAN CERTIFICATE',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            SizedBox(height: 24),

                            // Congratulations text
                            Text(
                              'CONGRATULATIONS',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                                letterSpacing: 2,
                              ),
                            ),

                            SizedBox(height: 20),

                            // Certificate text
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Dear Sir ', // Regular text
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: name, // Bold name
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.authorityBlue,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ', your loan has been approved. The World Bank has registered your proposed loan amount of ',
                                    ),
                                    TextSpan(
                                      text:
                                          '$loanBalance Rs.', // Bold loan amount
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.authorityBlue,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' for the purpose of evaluating the Poverty Alleviation Microfinance Project for Business Restructuring and Development. Agriculture business global practice, India Asia Region.',
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.justify,
                                softWrap: true,
                              ),
                            ),

                            SizedBox(height: 24),

                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.authorityBlue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      AppTheme.authorityBlue.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Agriculture business global practice Bangladesh Asia Region.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.authorityBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 24),

                            // Certificate details table
                            _buildCertificateDetails(),

                            SizedBox(height: 24),

                            // Signature and stamp section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (stampUrl.isNotEmpty)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Image.network(
                                          stampUrl,
                                          height: 100,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.red.shade200),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.broken_image,
                                                color: Colors.red.shade300),
                                          ),
                                        ),
                                        Text(
                                          'Official Stamp',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      if (signatureUrl.isNotEmpty)
                                        Image.network(
                                          signatureUrl,
                                          height: 40,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 40,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: Text('Signature',
                                                  style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic)),
                                            ),
                                          ),
                                        ),
                                      Container(
                                        margin: EdgeInsets.only(top: 8),
                                        width: 120,
                                        height: 1,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        'Authorized Signature',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Date section
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  time.isNotEmpty ? time : currentDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 24),

                            // Disclaimer
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                'This document has restricted distribution and may be used by recipients only for their official duties. Unauthorized use is prohibited.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateHeader() {
    return Column(
      children: [
        // IMF Logo
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber.shade300,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Seal_of_the_Reserve_Bank_of_India.svg/1200px-Seal_of_the_Reserve_Bank_of_India.svg.png',
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 80,
                width: 80,
                color: Colors.grey.shade200,
                child: Icon(Icons.account_balance,
                    size: 40, color: AppTheme.authorityBlue),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        // Bank Header
        Text(
          'World Bank International',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.authorityBlue,
            letterSpacing: 1.2,
          ),
        ),

        Text(
          'Loan Service',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppTheme.trustCyan,
            letterSpacing: 1,
          ),
        ),

        SizedBox(height: 4),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Text(
            'FOR OFFICIAL USE ONLY',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade800,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateDetails() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          _buildDetailRow('Loan Amount', '$loanBalance Rs.', true),
          _buildDetailRow('Interest Rate',
              interest.isNotEmpty ? '$interest%' : 'As per policy', false),
          _buildDetailRow(
              'Installments',
              installments.isNotEmpty ? installments : 'As per agreement',
              false),
          _buildDetailRow(
              'Contact', phone.isNotEmpty ? phone : 'On file', false),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool highlight) {
    return Container(
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.authorityBlue.withOpacity(0.05)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                  color: highlight ? AppTheme.authorityBlue : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
