import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/auth/SignupScreen.dart';
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  String countryCode = "+880"; // Default country code
  bool isLoading = false; // Flag for loading state

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  Future<void> _login() async {
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showErrorDialog('Phone and password are required!');
      return;
    }

    // Use countryCode in camelCase as the parameter name
    String formattedCountryCode =
        countryCode; // Keep the '+' in the country code

    setState(() {
      isLoading = true; // Set loading state
    });

    try {
      final response = await http.post(
        Uri.parse('https://app.wbli.org/api/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'countryCode': formattedCountryCode,
          // Use countryCode instead of country_code
          'phone': phone,
          'password': password,
        }),
      );

      setState(() {
        isLoading = false; // End loading
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(
            'Response Data: $responseData'); // Log response body for debugging

        if (responseData['success'] != null && responseData['success']) {
          // Save token and phone after successful login
          String token = responseData['token'];
          UserSession.saveSession(token, phone); // Save token and phone

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()),
            (Route<dynamic> route) => false, // This removes all previous routes
          );
        } else {
          print('Login Failed: ${responseData['message']}');
          _showErrorDialog(responseData['message'] ?? 'Login failed');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showErrorDialog('Failed to login. Please try again later.');
      }
    } catch (error) {
      setState(() {
        isLoading = false; // End loading in case of error
      });
      print('Error: $error');
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Center widget to center-align the content
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 400
                  ? 400
                  : double.infinity, // Fixed width for larger screens
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/app_logo.png", height: 120,width: 120,
                    ),
                    Text(
                      'Asian Development Bank',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Microfinance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.only(bottom: 1, top: 1),
                      child: CountryCodePicker(
                        onChanged: (country) {
                          setState(() {
                            countryCode = country.dialCode ?? "+880";
                          });
                        },
                        initialSelection: 'BD',
                        favorite: ['+880', 'BD'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                    ),
                    SizedBox(width: 2),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'মোবাইল নম্বর',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'পাসওয়ার্ড',
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'লগইন',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('একাউন্ট নেই?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        'নিবন্ধন করুন',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
