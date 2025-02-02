import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/screens/home_section/home_page.dart';
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';
import '../../slider/home_screen_slider.dart';
import 'dart:math';


class LoanApplicationScreen extends StatefulWidget {
  @override
  _LoanApplicationScreenState createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final List<int> loanAmounts = [
    100000,
    200000,
    300000,
    500000,
    800000,
    1000000,
    1200000,
    1500000,
    2000000,
    2500000
  ];
  final List<int> loanTerms = [12, 18, 24, 36, 48, 60];
  final double interestRate = 0.3;

  int selectedLoanAmount = 0;
  int selectedLoanTerm = 12;
  bool isLoading = false;

  double calculateInstallment(int loanAmount, int term) {
    double totalInterest = loanAmount * interestRate / 100 * term; // Apply interest monthly
    double totalAmount = loanAmount + totalInterest;
    return totalAmount / term;
  }



  // API সাবমিট ফাংশন
  Future<void> submitLoanApplication() async {
    setState(() => isLoading = true);

    String? token = await UserSession.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User token not found!')));
      setState(() => isLoading = false);
      return;
    }

    final apiUrl = 'https://app.wbli.org/api/loans'; 
    final loanData = {
      'amount': selectedLoanAmount.toString(),
      'interest_rate': interestRate.toString(),
      'loan_duration': selectedLoanTerm.toString(),
      'installment': selectedLoanTerm.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loanData),
      );

      print('Token: $token');
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Loan successfully submitted')));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit loan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => isLoading = false);
  }

  // UI বিল্ড
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asian Development Bank'),
      ),
      body: isLoading
          ? CircularProgressIndicator()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 6),

                  SliderSection(),
                  // মাস সিলেকশন
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Wrap(
                        spacing: 8.0,  // Space between the chips
                        runSpacing: 4.0,  // Space between the rows of chips
                        children: loanTerms.map((term) {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                selectedLoanTerm = term;
                                selectedLoanAmount = 0; // Reset selection
                              }),
                              child: Chip(
                                label: Text('$term মাস'),
                                backgroundColor: selectedLoanTerm == term
                                    ? Color(0xFF002336)
                                    : Colors.grey[300],
                                labelStyle: TextStyle(
                                    color: selectedLoanTerm == term
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),


                  // টাকার অংক + কিস্তি দেখানো
                  Column(
                    children: [
                      // টাকার অংক + কিস্তি দেখানো
                      ListView.builder(
                        shrinkWrap: true,
                        // Allow the ListView to take only the space it needs
                        physics: NeverScrollableScrollPhysics(),
                        // Prevent scrolling within ListView
                        itemCount: loanAmounts.length,
                        itemBuilder: (context, index) {
                          double installment = calculateInstallment(
                              loanAmounts[index], selectedLoanTerm);
                          bool isSelected =
                              selectedLoanAmount == loanAmounts[index];
                          return GestureDetector(
                            onTap: () => setState(() {
                              selectedLoanAmount = loanAmounts[index];
                            }),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? Color(0xFF00839E) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      spreadRadius: 1,
                                      blurRadius: 3)
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '৳${loanAmounts[index]}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '৳${installment.toStringAsFixed(2)} / $selectedLoanTerm মাস',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // সাবমিট বাটন
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedLoanAmount > 0
                                ? submitLoanApplication
                                : null, // সিলেক্ট করা না হলে বাটন ডিজেবল
                            style: ElevatedButton.styleFrom(
                              backgroundColor:Color(0xFF00839E),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('জমা দিন',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}


class SliderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10), child: HomeBannerSlider()),
    );
  }
}
