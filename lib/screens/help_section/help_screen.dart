import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../auth/saved_login/user_session.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_endpoints.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with SingleTickerProviderStateMixin {
  String? whatsappContact;
  String? telegramContact;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchContactDetails();

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to fetch the contact details using the API
  Future<void> _fetchContactDetails() async {
    try {
      String? token = await UserSession.getToken();
      if (token != null) {
        final response = await http.get(
          Uri.parse(ApiEndpoints.support),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        // Check if widget is still mounted before updating state
        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = json.decode(response.body); // Decode the JSON response
          setState(() {
            // Extract the whatsapp and telegram contact info from the JSON response
            whatsappContact = data['whatsapp'];
            telegramContact = data['telegram'];
            _isLoading = false;
          });
          _animationController.forward();
        } else {
          // Handle API failure
          setState(() {
            _isLoading = false;
          });
          _animationController.forward();
          _showErrorSnackbar('Failed to fetch contact details.');
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
      _showErrorSnackbar('Error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Function to launch the URL
  void _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Could not open $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.authorityBlue,
        centerTitle: true,
        title: Text(
          'Contact Us',
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
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.authorityBlue,
                  AppTheme.trustCyan,
                  AppTheme.backgroundLight,
                ],
                stops: [0.0, 0.2, 0.4],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Main content container
                              Container(
                                width: isMobile ? double.infinity : 450,
                                padding: EdgeInsets.all(24),
                                margin: EdgeInsets.only(top: 20, bottom: 30),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Support Icon
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.trustCyan.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.support_agent,
                                        size: isMobile ? 60 : 70,
                                        color: AppTheme.trustCyan,
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),

                                    // Support heading
                                    Text(
                                      "Customer Support",
                                      style: TextStyle(
                                        fontSize: isMobile ? 22 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.neutral800,
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 12 : 16),

                                    // Support description
                                    Text(
                                      "You can contact us through any of the methods below or make an appointment to visit the office directly.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        color: AppTheme.neutral700,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),

                                    // Office address container
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppTheme.neutral200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.authorityBlue
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.location_on,
                                              color: AppTheme.authorityBlue,
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Office Address",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.neutral800,
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  "The World Bank, No 11, Taramani Link Rd, Tharamani, Chennai, Tamil Nadu 600113, India",
                                                  style: TextStyle(
                                                    fontSize:
                                                        isMobile ? 12 : 14,
                                                    color: AppTheme.neutral700,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 24),

                                    // Loading indicator or contact options
                                    if (_isLoading)
                                      Column(
                                        children: [
                                          CircularProgressIndicator(
                                            color: AppTheme.trustCyan,
                                            strokeWidth: 3,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "Loading contact details...",
                                            style: TextStyle(
                                              color: AppTheme.neutral600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (whatsappContact != null &&
                                        telegramContact != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Direct Contact Options",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.neutral800,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          ContactOption(
                                            icon: FontAwesomeIcons.whatsapp,
                                            color: Colors.green,
                                            title: "Contact via WhatsApp",
                                            contact: whatsappContact!,
                                            onTap: () => _launchURL(
                                                "https://wa.me/$whatsappContact"),
                                            isMobile: isMobile,
                                          ),
                                          SizedBox(height: 12),
                                          ContactOption(
                                            icon: FontAwesomeIcons.telegram,
                                            color: Colors.blueAccent,
                                            title: "Contact via Telegram",
                                            contact: telegramContact!,
                                            onTap: () => _launchURL(
                                                "https://t.me/$telegramContact"),
                                            isMobile: isMobile,
                                          ),
                                        ],
                                      )
                                    else
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.orange,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Contact information not available. Please try again later.",
                                                style: TextStyle(
                                                  color: Colors.orange.shade800,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Support hours and additional info
                              if (!_isLoading)
                                Container(
                                  width: isMobile ? double.infinity : 450,
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Support Hours",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.neutral800,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      SupportHoursRow(
                                        day: "Monday - Friday",
                                        hours: "9:00 AM - 6:00 PM",
                                      ),
                                      SizedBox(height: 8),
                                      SupportHoursRow(
                                        day: "Saturday",
                                        hours: "10:00 AM - 4:00 PM",
                                      ),
                                      SizedBox(height: 8),
                                      SupportHoursRow(
                                        day: "Sunday",
                                        hours: "Closed",
                                        isClosed: true,
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.trustCyan
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: AppTheme.trustCyan,
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Our support team typically responds within 24 hours on business days.",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.neutral700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportHoursRow extends StatelessWidget {
  final String day;
  final String hours;
  final bool isClosed;

  const SupportHoursRow({
    super.key,
    required this.day,
    required this.hours,
    this.isClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isClosed ? Colors.red.shade300 : Colors.green.shade300,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.neutral700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isClosed ? FontWeight.normal : FontWeight.bold,
              color: isClosed ? Colors.red.shade400 : AppTheme.neutral800,
            ),
          ),
        ),
      ],
    );
  }
}

class ContactOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String contact;
  final VoidCallback onTap;
  final bool isMobile;

  const ContactOption({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.contact,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isMobile ? 18 : 22,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutral800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        contact,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: AppTheme.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new,
                        color: color,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Open",
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
