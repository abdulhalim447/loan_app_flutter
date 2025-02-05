import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../auth/saved_login/user_session.dart'; // Ensure this import is correct

class GetWithdraw extends StatefulWidget {
  @override
  _GetWithdrawState createState() => _GetWithdrawState();
}

class _GetWithdrawState extends State<GetWithdraw> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  // Function to make API call
  Future<void> _submitData() async {
    // Get token from UserSession
    String? token = await UserSession.getToken();

    // Check if token is null or if the amount or pin is empty
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please login again.')),
      );
      return;
    }

    if (_amountController.text.isEmpty || _pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Amount and Pin cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://app.wbli.org/api/withdraw'),
        headers: {
          'Authorization': 'Bearer $token',
          //'Content-Type': 'application/json',
        },
        body: {
          'amount': _amountController.text,
          'pin': _pinController.text,
        },
      );

      if (response.statusCode == 201) {
        _amountController.clear();
        _pinController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdraw Request Submitted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('টাকা তুলুন')),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: screenWidth > 600 ? 600 : screenWidth,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                // Amount TextField with decoration and text color
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'টাকার পরিমান',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Color(0xFF00839E),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),

                // Pin TextField with decoration and text color
                TextField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'উত্তোলন পিন',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Color(0xFF00839E),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),

                // Submit Button with loading indicator
                SizedBox(
                  width: double.maxFinite,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitData,
                          child: Text('জমা দিন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00839E),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                            textStyle: TextStyle(fontSize: 18),
                          ),
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
