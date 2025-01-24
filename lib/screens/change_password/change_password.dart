import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // টেক্সট ফিল্ডের জন্য কন্ট্রোলার
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // লোডিং স্টেট

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    final url = 'https://app.wbli.org/api/change-password'; // এখানে API URL দিন

    // টোকেন সংগ্রহ করা
    String? token = await UserSession.getToken();

    if (token == null) {
      // টোকেন না থাকলে, ব্যবহারকারীকে লগ ইন করতে বলুন
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in. Please log in again.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // লোডিং শুরু
    });

    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'current_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPasswordController.text, // কনফার্ম পাসওয়ার্ড
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // টোকেন হেডারে পাঠানো
      },
    );

    setState(() {
      _isLoading = false; // লোডিং শেষ
    });

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password change successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Change your password'),
      ),
      body: Container(
        width: screenWidth > 600 ? 600 : screenWidth,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPasswordField(
                  label: 'পূরাতন পাসওয়ার্ড',
                  controller: oldPasswordController,
                  obscureText: _obscureOldPassword,
                  toggleObscureText: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                _buildPasswordField(
                  label: 'নতুন পাসওয়ারড',
                  controller: newPasswordController,
                  obscureText: _obscureNewPassword,
                  toggleObscureText: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                _buildPasswordField(
                  label: 'কনফার্ম পাসওয়াররড',
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  toggleObscureText: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                SizedBox(height: 24.0),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscureText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // White color for label
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // White border color
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // White border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // White border when focused
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.white, // White icon color
          ),
          onPressed: toggleObscureText,
        ),
      ),
      style: TextStyle(color: Colors.white), // White text color
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (label == 'New password' && value != newPasswordController.text) {
          return 'Passwords didn\'t match';
        }
        if (label == 'Confirm Password' && value != newPasswordController.text) {
          return 'Passwords didn\'t match';
        }
        return null;
      },
    );
  }


  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
          if (_formKey.currentState?.validate() ?? false) {
            // পাসওয়ার্ড পরিবর্তনের API কল করা
            _changePassword(
              oldPasswordController.text,
              newPasswordController.text,
            );
          }
        },
        child: _isLoading
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Text('সেইভ'),
      ),
    );
  }

  @override
  void dispose() {
    // কন্ট্রোলারগুলো ডিসপোজ করা
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
