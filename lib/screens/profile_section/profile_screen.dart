import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:world_bank_loan/auth/LoginScreen.dart';
import 'package:world_bank_loan/screens/ComplaintFormScreen/ComplaintFormScreen.dart';
import 'package:world_bank_loan/screens/change_password/change_password.dart';
import 'package:world_bank_loan/screens/personal_information/personal_information.dart';
import 'package:world_bank_loan/screens/terms_and_condition/terms_and_condition.dart';
import '../../auth/saved_login/user_session.dart';
import '../../core/theme/app_theme.dart';
import '../AboutMeScreen/AboutMeScreen.dart';
import '../bank_account/bank_account.dart';
import '../loan_certifacte/loan_certificate.dart';
import '../user_agrements/user_agrements_screen.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String number = "0";
  String name = "Loading...";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _getUserData();

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

    _animationController.forward();

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

  Future<void> _getUserData() async {
    String? token = await UserSession.getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse(ApiEndpoints.profile),
        headers: {'Authorization': 'Bearer $token'},
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          number = data['number'] ?? "0"; // Safe null check
          name = data['name'] ?? "No Name"; // Safe null check
        });
      } else {
        // Handle error
        setState(() {
          number = "0";
          name = "Failed to load data";
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Confirm Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.authorityBlue,
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: AppTheme.neutral700),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: AppTheme.neutral600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Remove user session from SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                prefs.remove('phone');

                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            LoginScreen())); // Redirect to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authorityBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Yes, Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.authorityBlue,
        centerTitle: true,
        title: Text(
          'Profile',
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

          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Profile Header with updated styling
                      ProfileHeader(number: number, name: name),

                      // Profile Options in a scrollable list
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, -5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: ListView(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              children: [
                                // Section Title - Account
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, bottom: 8, top: 8),
                                  child: Text(
                                    'Account Settings',
                                    style: TextStyle(
                                      color: AppTheme.neutral700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                ProfileOption(
                                  icon: FontAwesomeIcons.university,
                                  text: 'Personal Information',
                                  subtitle: 'Manage your personal details',
                                  color: AppTheme.authorityBlue,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                PersonalInfoScreen()));
                                  },
                                ),
                                // ProfileOption(
                                //   icon: FontAwesomeIcons.moneyBill,
                                //   text: 'Bank Account',
                                //   subtitle: 'Manage your bank details',
                                //   color: Colors.green,
                                //   onTap: () {
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (builder) =>
                                //                 BankAccountScreen()));
                                //   },
                                // ),

                                ProfileOption(
                                  icon: FontAwesomeIcons.lock,
                                  text: 'Change Password',
                                  subtitle: 'Update your security credentials',
                                  color: Colors.orange,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                ChangePasswordScreen()));
                                  },
                                ),

                                SizedBox(height: 4),

                                // Section Title - Documentation
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, bottom: 8, top: 16),
                                  child: Text(
                                    'Documents & Certificates',
                                    style: TextStyle(
                                      color: AppTheme.neutral700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                ProfileOption(
                                  icon: FontAwesomeIcons.certificate,
                                  text: 'Loan Certificate',
                                  subtitle: 'View your loan documentation',
                                  color: AppTheme.authorityBlue,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                LoanCertificatePage()));
                                  },
                                ),
                                ProfileOption(
                                  icon: FontAwesomeIcons.userLarge,
                                  text: 'Agreements',
                                  subtitle: 'View your loan agreements',
                                  color: Colors.purple,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                LoanDetailsScreen()));
                                  },
                                ),

                                SizedBox(height: 4),

                                // Section Title - Support
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, bottom: 8, top: 16),
                                  child: Text(
                                    'Support & Legal',
                                    style: TextStyle(
                                      color: AppTheme.neutral700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

/*
                                ProfileOption(
                                  icon: FontAwesomeIcons.plusCircle,
                                  text: 'Complain',
                                  subtitle:
                                      'Submit feedback or file a complaint',
                                  color: Colors.red,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                ComplaintFormScreen()));
                                  },
                                ),
*/

                                ProfileOption(
                                  icon: FontAwesomeIcons.shieldAlt,
                                  text: 'Terms and Condition',
                                  subtitle: 'View app terms and conditions',
                                  color: AppTheme.trustCyan,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                TermsAndConditionScreen()));
                                  },
                                ),

                                SizedBox(height: 24),

                                // Logout Button
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: () => _logout(context),
                                    icon: Icon(
                                      FontAwesomeIcons.powerOff,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 3,
                                      shadowColor:
                                          Colors.redAccent.withOpacity(0.4),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String number;
  final String name;

  const ProfileHeader({super.key, required this.number, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(
                Icons.person,
                size: 48,
                color: AppTheme.authorityBlue,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.text,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
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
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutral800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.neutral400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
