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

    final String apiUrl = 'https://wbli.org/api/complaint';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Complain'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Your number', yourNameController),
              SizedBox(height: 8.0),
              _buildTextField('Website', websiteController),
              SizedBox(height: 8.0),
              _buildTextField('Service number', providerNameController),
              SizedBox(height: 8.0),
              _buildTextField('Loss details', totalDamageController),
              SizedBox(height: 16.0),
              _buildSubmitButton(),
            ],
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
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Fill up all fields';
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
        child: Text('Submit'),
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
