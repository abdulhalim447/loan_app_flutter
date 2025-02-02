import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:world_bank_loan/auth/LoginScreen.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';
import 'package:world_bank_loan/screens/ComplaintFormScreen/ComplaintFormScreen.dart';
import 'package:world_bank_loan/screens/change_password/change_password.dart';
import 'package:world_bank_loan/screens/data_delete_screen/data_delete_screen.dart';
import 'package:world_bank_loan/screens/personal_information/personal_information.dart';
import 'package:world_bank_loan/screens/privacy_policy_screen/privacy_policy_screen.dart';
import 'package:world_bank_loan/screens/terms_and_condition/terms_and_condition.dart';
import '../../auth/saved_login/user_session.dart';
import '../AboutMeScreen/AboutMeScreen.dart';
import '../bank_account/bank_account.dart';
import '../kisti_details/kisti_details.dart';
import '../user_agrements/user_agrements_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String number = "0";
  String name = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadStoredUserData();
    _getUserData();
  }

  Future<void> _loadStoredUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      number = prefs.getString('number') ?? "0";
      name = prefs.getString('name') ?? "Loading...";
    });
  }

  Future<void> _saveUserData(String number, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('number', number);
    await prefs.setString('name', name);
  }

  Future<void> _getUserData() async {
    String? token = await UserSession.getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('https://app.wbli.org/api/index'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        String newNumber = data['number'] ?? "0";
        String newName = data['name'] ?? "No Name";

        // Update only if data has changed
        if (number != newNumber || name != newName) {
          await _saveUserData(
              newNumber, newName); // Save new data in SharedPreferences
          setState(() {
            number = newNumber;
            name = newName;
          });
        }
      } else {
        // Handle error
        setState(() {
          number = "0";
          name = "Failed to load data";
        });
      }
    } else {
      setState(() {
        number = "0";
        name = "Token is null";
      });
    }
  }

  // logout ============================================================
  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                prefs.remove('phone');

                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (builder) => LoginScreen()));
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  //============================================================
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
        backgroundColor: Color(0xFF002336),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('প্রোফাইল'),
        ),
        body: Center(
          child: Container(
            width: screenWidth > 600 ? 600 : screenWidth, // Max width 400px
            child: Column(
              children: [
                ProfileHeader(number: number, name: name),
                Expanded(
                  child: ListView(
                    children: [
                      ProfileOption(
                        icon: FontAwesomeIcons.university,
                        text: 'ব্যক্তিগত তথ্য',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => PersonalInfoScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.moneyBill,
                        text: 'ব্যাংক একাউন্ট',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => BankAccountScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.infoCircle,
                        text: 'আমার সম্পর্কে',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => AboutMeScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.plusCircle,
                        text: 'অভিযোগ করুন',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ComplaintFormScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.lock,
                        text: 'পাসওয়ার্ড পরিবর্তন করুন',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ChangePasswordScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.shieldAlt,
                        text: 'শর্তাবলী',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      TermsAndConditionScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.warning,
                        text: 'প্রাইভেসি পলিসি ',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => PrivacyPolicyScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.remove,
                        text: 'ডাটা ডিলিট পলিসি',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      DataDeletionPolicyScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.certificate,
                        text: 'কিস্তির বিবরণ',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => KistiDetailsScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.userLarge,
                        text: 'চুক্তি',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => LoanDetailsScreen()));
                        },
                      ),
                      ProfileOption(
                        icon: FontAwesomeIcons.powerOff,
                        text: 'লগ-আউট',
                        onTap: () {
                          _logout(context);
                        },
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

class ProfileHeader extends StatelessWidget {
  final String number;
  final String name;

  ProfileHeader({required this.number, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: Color(0xFF00839E),
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            number,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
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
  final VoidCallback onTap;

  ProfileOption({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF00839E)),
        title: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
        trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF00839E)),
        onTap: onTap,
      ),
    );
  }
}
