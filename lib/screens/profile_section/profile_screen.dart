import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:world_bank_loan/auth/LoginScreen.dart';
import 'package:world_bank_loan/screens/ComplaintFormScreen/ComplaintFormScreen.dart';
import 'package:world_bank_loan/screens/change_password/change_password.dart';
import 'package:world_bank_loan/screens/personal_information/personal_information.dart';
import 'package:world_bank_loan/screens/terms_and_condition/terms_and_condition.dart';
import '../../auth/saved_login/user_session.dart';
import '../AboutMeScreen/AboutMeScreen.dart';
import '../bank_account/bank_account.dart';

import '../loan_certifacte/loan_certificate.dart';
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
    _getUserData();
  }

  Future<void> _getUserData() async {
    String? token = await UserSession.getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('https://wbli.org/api/index'), // Replace with your API URL
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
                // Remove user session from SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                prefs.remove('phone');

                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            LoginScreen())); // Redirect to login screen (change as per your app's navigation)
              },
              child: Text("Yes"),
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
        title: Text('Profile'),
      ),
      body: Column(
        children: [
          // Pass updated name and number to ProfileHeader
          ProfileHeader(number: number, name: name),
          Expanded(
            child: ListView(
              children: [
                ProfileOption(
                  icon: FontAwesomeIcons.university,
                  text: 'Personal Information',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => PersonalInfoScreen()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.moneyBill,
                  text: 'Bank Account',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => BankAccountScreen()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.infoCircle,
                  text: 'About Me',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => AboutMeScreen()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.plusCircle,
                  text: 'Complain',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => ComplaintFormScreen()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.lock,
                  text: 'Change Password',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => ChangePasswordScreen()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.shieldAlt,
                  text: 'Terms and Condition',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => TermsAndConditionScreen()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.warning,
                  text: 'Privacy Policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Comming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.remove,
                  text: 'Data Delete policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Comming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.certificate,
                  text: 'Loan Certificate',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => LoanCertificatePage()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.userLarge,
                  text: 'Agreements',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => LoanDetailsScreen()));
                  },
                ),
                ProfileOption(
                  icon: FontAwesomeIcons.powerOff,
                  text: 'Logout',
                  onTap: () {
                    _logout(context);
                  },
                ),
              ],
            ),
          ),
        ],
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
            color: Colors.black54,
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            number,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
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
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[800]),
        title: Text(text, style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
