import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding
import 'package:world_bank_loan/auth/LoginScreen.dart';
import 'package:world_bank_loan/auth/saved_login/user_session.dart';

import '../bottom_navigation/MainNavigationScreen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool isLoading = false; // New variable to manage loading state
  String countryCode = "+91"; // Default country code

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
    confirmPasswordVisible = false;
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      confirmPasswordVisible = !confirmPasswordVisible;
    });
  }

/*  // Function to handle sign up API request
  Future<void> _signUp() async {
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog('All fields are required!');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match!');
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse('https://wbli.org/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'countryCode': countryCode,
          'phone': phone,
          'password': password,
          'c_password': confirmPassword,
        }),
      );

      setState(() {
        isLoading = false; // Stop loading
      });

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['message'] == 'User registered successfully!') {
          // Registration was successful, navigate to LoginScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          _showErrorDialog(responseData['message'] ?? 'Registration failed');
        }
      } else {
        _showErrorDialog('Failed to sign up. Please try again later.');
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
      _showErrorDialog('An error occurred. Please try again.');
    }
  }


 */

  Future<void> _signUp() async {
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog('All fields are required!');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match!');
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      // Registration request
      final registerResponse = await http.post(
        Uri.parse('https://wbli.org/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'countryCode': countryCode,
          'phone': phone,
          'password': password,
          'c_password': confirmPassword,
        }),
      );

      if (registerResponse.statusCode == 201) {
        final Map<String, dynamic> registerData =
            json.decode(registerResponse.body);

        if (registerData['message'] == 'User registered successfully!') {
          // Automatically login the user
          final loginResponse = await http.post(
            Uri.parse('https://wbli.org/api/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'countryCode': countryCode,
              'phone': phone,
              'password': password,
            }),
          );

          setState(() {
            isLoading = false; // Stop loading
          });

          if (loginResponse.statusCode == 200) {
            final Map<String, dynamic> loginData =
                json.decode(loginResponse.body);

            if (loginData['success'] != null && loginData['success']) {
              // Save session
              String token = loginData['token'];
              UserSession.saveSession(token, phone);

              // Navigate to MainNavigationScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainNavigationScreen()),
              );
            } else {
              _showErrorDialog(loginData['message'] ?? 'Login failed');
            }
          } else {
            _showErrorDialog('Failed to login after registration.');
          }
        } else {
          setState(() {
            isLoading = false; // Stop loading
          });
          _showErrorDialog(registerData['message'] ?? 'Registration failed');
        }
      } else {
        setState(() {
          isLoading = false; // Stop loading
        });
        _showErrorDialog('Failed to register. Please try again later.');
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

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
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600
                  ? 400
                  : double.infinity, // ওয়েব স্ক্রিনের জন্য নির্দিষ্ট প্রস্থ
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Column(
                  children: [
                    Icon(
                      Icons.public,
                      size: screenWidth > 600 ? 100 : 80,
                      // স্ক্রিন সাইজ অনুযায়ী আইকনের আকার পরিবর্তন
                      color: Colors.blue,
                    ),
                    Text(
                      'World Bank Development',
                      style: TextStyle(
                        fontSize: screenWidth > 600 ? 28 : 24,
                        // স্ক্রিন সাইজ অনুযায়ী টেক্সট সাইজ
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Micro Finance',
                      style: TextStyle(
                        fontSize: screenWidth > 600 ? 18 : 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: CountryCodePicker(
                        onChanged: (country) {
                          setState(() {
                            countryCode = country.dialCode ?? "+91";
                          });
                        },
                        initialSelection: 'IN',
                        favorite: ['+91', 'IN'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Password Field with validation
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  keyboardType: TextInputType.text,
                  // Keep this as text input for the password
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                    errorText: passwordController.text.length != 6 &&
                            passwordController.text.isNotEmpty
                        ? 'Password must be 6 digits'
                        : null, // Display error if password length is not 6 digits
                  ),
                ),

                SizedBox(height: 20),

// Confirm Password Field with validation
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !confirmPasswordVisible,
                  keyboardType: TextInputType.text, // Keep this as text input
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed:
                          toggleConfirmPasswordVisibility, // Toggle visibility
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorText:
                        _confirmPasswordError(), // Show error if passwords don't match
                  ),
                ),

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signUp,
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
                            'Register',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text('Already have an account?'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Login',
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

  // Helper method to check confirm password validity
  String? _confirmPasswordError() {
    // If both password and confirmPassword fields are filled, check if they match
    if (confirmPasswordController.text.isEmpty) {
      return null; // No error if the field is empty
    }
    if (confirmPasswordController.text != passwordController.text) {
      return 'Passwords do not match'; // Error if passwords do not match
    }
    return null; // No error if passwords match
  }
}
