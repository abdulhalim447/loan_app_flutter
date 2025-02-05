import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/saved_login/user_session.dart';

class KistiDetailsScreen extends StatefulWidget {
  @override
  _KistiDetailsScreenState createState() => _KistiDetailsScreenState();
}

class _KistiDetailsScreenState extends State<KistiDetailsScreen> {
  bool isLoading = true;
  Map<String, dynamic> loanData = {};
  List<String> installmentDates = [];
  double installmentsPerMonth = 0;

  @override
  void initState() {
    super.initState();
    fetchInstallmentsDetails();
  }

  // API কল এবং ডাটা আপডেট করার ফাংশন
  Future<void> fetchInstallmentsDetails() async {
    String? token = await UserSession.getToken();
    final response = await http.get(
      Uri.parse('https://app.wbli.org/api/installments'), // API URL
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        loanData = {
          'totalAmount': data['totalAmount'],
          'loanDuration': data['loanDuration'],
          'totalInstallments': data['totalInstallments'],
        };

        // Get the installment amount and dates
        installmentsPerMonth = data['installmentsPerMonth'];
        installmentDates = List<String>.from(data['installmentDates']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('কিস্তির বিবরণ'),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: screenWidth > 600 ? 600 : screenWidth,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Loan details section
                        Text(
                          'Total Loan Amount: BDT ${loanData['totalAmount']}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          'Loan Duration: ${loanData['loanDuration']} months',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          'Total Installments: ${loanData['totalInstallments']}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 20),

                        // Installment details section
                        Text(
                          'Installments Per Month: BDT $installmentsPerMonth',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Installment Dates:',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: installmentDates.length,
                          itemBuilder: (context, index) {
                            var dueDate = installmentDates[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 5,
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Due Date: $dueDate',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Amount: BDT $installmentsPerMonth',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      'Unpaid', // You can modify the status
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
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
                  ),
                ),
        ),
      ),
    );
  }
}
