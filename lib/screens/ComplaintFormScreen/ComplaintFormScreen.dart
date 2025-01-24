import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../auth/saved_login/user_session.dart';

class ComplaintFormScreen extends StatefulWidget {
  @override
  _ComplaintFormScreenState createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController yourNameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController providerNameController = TextEditingController();
  final TextEditingController totalDamageController = TextEditingController();

  // Method to submit complaint
  Future<void> _submitComplaint() async {
    String? token = await UserSession.getToken(); // Get the token from session

    if (token == null) {
      // If no token found, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found! Please login again.')),
      );
      return;
    }

    final String apiUrl = 'https://app.wbli.org/api/complaint';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token', // Add token to the Authorization header
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone_number': yourNameController.text,
        'website': websiteController.text,
        'loss_detail': totalDamageController.text,
        'service': providerNameController.text,
      }),
    );

    if (response.statusCode == 201) {
      // If the response is successful (201 Created)
      final responseBody = jsonDecode(response.body);
      final message = responseBody['message'] ?? 'Complaint submitted successfully';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      // Optionally, you can clear the form fields here
      yourNameController.clear();
      websiteController.clear();
      providerNameController.clear();
      totalDamageController.clear();
    } else {
      // Handle failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit complaint. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Complain'),
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
                _buildTextField('আপনার নম্বর', yourNameController),
                SizedBox(height: 8.0),
                _buildTextField('ওয়েবসাইট', websiteController),
                SizedBox(height: 8.0),
                _buildTextField('সার্ভিস নম্বর', providerNameController),
                SizedBox(height: 8.0),
                _buildTextField('ক্ষতির বিবরণ', totalDamageController),
                SizedBox(height: 16.0),
                _buildSubmitButton(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
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
      ),
      style: TextStyle(color: Colors.white), // White text color
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Fill up all fields'; // Validation message
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            // Submit the complaint when the form is valid
            _submitComplaint();
          }
        },
        child: Text('সাবমিট'),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    yourNameController.dispose();
    websiteController.dispose();
    providerNameController.dispose();
    totalDamageController.dispose();
    super.dispose();
  }
}
