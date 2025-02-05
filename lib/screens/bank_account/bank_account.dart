import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asian_development_bank/screens/loan_apply_screen/loan_apply_screen.dart';
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';

class BankAccountScreen extends StatefulWidget {
  @override
  _BankAccountScreenState createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ifcCode = TextEditingController();

  bool isEditable = true; // To control whether the form is editable
  bool isLoading = false; // To show a loading spinner while fetching data

  // Method to fetch bank details from API
  Future<void> _fetchBankDetails() async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    String? token = await UserSession.getToken();
    if (token == null) {
      // If token is not found, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found! Please login again.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String apiUrl = 'https://app.wbli.org/api/getbank';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final data = responseBody['data'];

      if (data != null && data['bankStatus'] == 1) {
        // If bankStatus is 1, populate the fields and make them editable
        accountHolderController.text = data['bankUserName'] ?? '';
        bankNameController.text = data['bankName'] ?? '';
        accountNumberController.text = data['account'] ?? '';
        ifcCode.text = data['ifc'] ?? '';
        setState(() {
          isEditable = false;
        });
      } else {
        // If bankStatus is not 1, make fields uneditable
        setState(() {
          isEditable = true;
        });
      }
    } else {
      // If the API call failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch bank details. Please try again.')),
      );
    }

    setState(() {
      isLoading = false; // Hide loading indicator after fetching data
    });
  }

  // Method to save bank details
  Future<void> _saveBankDetails() async {
    String? token = await UserSession.getToken(); // Get token from UserSession

    if (token == null) {
      // If token is not found, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found! Please login again.')),
      );
      return;
    }

    final String apiUrl = 'https://app.wbli.org/api/savebank';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BankuserName': accountHolderController.text,
        'bankName': bankNameController.text,
        'account': accountNumberController.text,
        'ifc': ifcCode.text,
        'bankUserName': accountHolderController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => LoanApplicationScreen()));
      final responseBody = jsonDecode(response.body);
      accountNumberController.clear();
      accountHolderController.clear();
      bankNameController.clear();
      ifcCode.clear();
      final message =
          responseBody['message'] ?? 'Bank details updated successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update bank details. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBankDetails(); // Fetch bank details when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('ব্যাংক একাউন্ট তথ্য'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: screenWidth > 600 ? 600 : screenWidth,
          child: SingleChildScrollView(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(), // Show loading spinner
            )
                : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('ব্যাংক একাউন্ট তথ্য'),
                    SizedBox(height: 16.0),
                    _buildTextField('অ্যাকাউন্ট হোল্ডারের নাম', accountHolderController),
                    SizedBox(height: 8.0),
                    _buildTextField('ব্যাংকের নাম', bankNameController),
                    SizedBox(height: 8.0),
                    _buildTextField('অ্যাকাউন্ট নম্বর', accountNumberController,
                        keyboardType: TextInputType.number),
                    SizedBox(height: 8.0),
                    _buildTextField('শাখা', ifcCode),
                    SizedBox(height: 16.0),
                    _buildSaveButton(),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }


  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: isEditable, // Set field editable based on bankStatus
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
        disabledBorder:  OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // White border when focused
        ),
      ),
      style: TextStyle(color: Colors.white), // White text color
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  // Save Button Widget
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEditable
            ? () {
          if (_formKey.currentState?.validate() ?? false) {
            _saveBankDetails();
          }
        }
            : null, // Disable button if not editable
        child: Text('জমা দিন'),

      ),
    );
  }

  @override
  void dispose() {
    accountNumberController.dispose();
    accountHolderController.dispose();
    bankNameController.dispose();
    ifcCode.dispose();
    super.dispose();
  }
}
