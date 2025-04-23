import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // এইচটিটিপি প্যাকেজ ইমপোর্ট করুন
import 'package:world_bank_loan/auth/LoginScreen.dart';
import 'package:world_bank_loan/screens/bank_account/bank_account.dart';
import 'package:world_bank_loan/screens/change_password/change_password.dart';
import 'package:world_bank_loan/screens/personal_information/personal_information.dart';
import 'package:world_bank_loan/screens/terms_and_condition/terms_and_condition.dart';
import '../../auth/saved_login/user_session.dart';
import '../../core/theme/app_theme.dart';
import '../user_agrements/user_agrements_screen.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String number = "০";
  String name = "লোড হচ্ছে...";
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

    // স্ট্যাটাস বার আইকন সাদা করুন
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
          number = data['number'] ?? "০"; // Safe null check
          name = data['name'] ?? "কোন নাম নেই"; // Safe null check
        });
      } else {
        // Handle error
        setState(() {
          number = "০";
          name = "ডাটা লোড করতে ব্যর্থ হয়েছে";
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    // নিশ্চিতকরণ ডায়ালগ দেখান
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "লগআউট নিশ্চিত করুন",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.authorityBlue,
            ),
          ),
          content: Text(
            "আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?",
            style: TextStyle(color: AppTheme.neutral700),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ডায়ালগ বন্ধ করুন
              },
              child: Text(
                "বাতিল করুন",
                style: TextStyle(color: AppTheme.neutral600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // SharedPreferences থেকে ইউজার সেশন সরান
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                prefs.remove('phone');

                Navigator.of(context).pop(); // ডায়ালগ বন্ধ করুন
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            LoginScreen())); // লগইন স্ক্রিনে রিডাইরেক্ট করুন
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authorityBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("হ্যাঁ, লগআউট করুন"),
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
          'প্রোফাইল',
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
          // গ্রেডিয়েন্ট ব্যাকগ্রাউন্ড
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
                      // আপডেট করা স্টাইলিং সহ প্রোফাইল হেডার
                      ProfileHeader(number: number, name: name),

                      // স্ক্রোলযোগ্য তালিকায় প্রোফাইল অপশন
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
                                // বিভাগ শিরোনাম - অ্যাকাউন্ট
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, bottom: 8, top: 8),
                                  child: Text(
                                    'অ্যাকাউন্ট সেটিংস',
                                    style: TextStyle(
                                      color: AppTheme.neutral700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                ProfileOption(
                                  icon: FontAwesomeIcons.university,
                                  text: 'ব্যক্তিগত তথ্য',
                                  subtitle:
                                      'আপনার ব্যক্তিগত বিবরণ পরিচালনা করুন',
                                  color: AppTheme.authorityBlue,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                PersonalInfoScreen()));
                                  },
                                ),
                                ProfileOption(
                                  icon: FontAwesomeIcons.moneyBill,
                                  text: 'ব্যাংক অ্যাকাউন্ট',
                                  subtitle: 'আপনার ব্যাংক বিবরণ পরিচালনা করুন',
                                  color: Colors.green,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                BankAccountScreen()));
                                  },
                                ),

                                ProfileOption(
                                  icon: FontAwesomeIcons.lock,
                                  text: 'পাসওয়ার্ড পরিবর্তন করুন',
                                  subtitle:
                                      'আপনার নিরাপত্তা শংসাপত্র আপডেট করুন',
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

                                // বিভাগ শিরোনাম - ডকুমেন্টেশন
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, bottom: 8, top: 16),
                                  child: Text(
                                    'ডকুমেন্টস এবং সার্টিফিকেট',
                                    style: TextStyle(
                                      color: AppTheme.neutral700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                ProfileOption(
                                  icon: FontAwesomeIcons.userLarge,
                                  text: 'চুক্তিসমূহ',
                                  subtitle: 'আপনার লোন চুক্তিগুলি দেখুন',
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

                                // বিভাগ শিরোনাম - সাপোর্ট
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, bottom: 8, top: 16),
                                  child: Text(
                                    'সাপোর্ট এবং আইনি',
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
                                  text: 'অভিযোগ',
                                  subtitle:
                                      'মতামত জমা দিন বা অভিযোগ দায়ের করুন',
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
                                  text: 'শর্তাবলী',
                                  subtitle: 'অ্যাপের শর্তাবলী দেখুন',
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

                                // লগআউট বাটন
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
                                      'লগআউট',
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
