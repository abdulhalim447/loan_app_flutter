import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON ডাটা পার্স করার জন্য

import '../../auth/saved_login/user_session.dart';


class LoanDetailsScreen extends StatefulWidget {
  const LoanDetailsScreen({Key? key}) : super(key: key);

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  bool hasLoan = false;
  String borrowerName = "";
  String loanTime = "";
  String loanAmount = "";
  String loanInstallments = "";
  String monthlyInterestRate = "";
  String contactNumber = "";
  String borrowerSignature = "";
  String lenderSignature = "";
  String loanStamp = "";

  @override
  void initState() {
    super.initState();
    _fetchLoanData();
  }

  // API থেকে ডাটা ফেচ করার জন্য এই মেথডটি ব্যবহার করা হবে
  Future<void> _fetchLoanData() async {
    // টোকেন নিন
    String? token = await UserSession.getToken();

    // যদি টোকেন না থাকে, তাহলে কোনো API কল হবে না
    if (token == null) {
      return;
    }

    // API কল করার জন্য হেডার তৈরি
    final response = await http.get(
      Uri.parse('https://wbli.org/api/aggrement'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        hasLoan = data['hasLoan'] ?? false;

        if (hasLoan) {
          borrowerName = data['name'] ?? "N/A";
          loanTime = data['LoanCreationTime'] ?? "Unknown";
          loanAmount = data['loan_amount'] ?? "0";
          loanInstallments = data['installments'] ?? "0";
          monthlyInterestRate = data['intrest_rate'] ?? "0%";
          contactNumber = data['phone'] ?? "N/A";
          borrowerSignature = data['user_signature'] ?? "";
          loanStamp = data['stamp'] ?? "";
        }
      });
    } else {
      print('Failed to load loan data');
    }

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreements'),
      ),
      body: Center(
        child: Container(
          width: screenWidth > 600 ? 600 : screenWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // যদি লোন পাওয়া যায়, তাহলে তথ্যগুলো দেখাবে
                hasLoan
                    ? LoanTableWidget(
                        borrowerName: borrowerName,
                        loanTime: loanTime,
                        loanAmount: loanAmount,
                        loanInstallments: loanInstallments,
                        monthlyInterestRate: monthlyInterestRate,
                        contactNumber: contactNumber,
                      )
                    : Center(child: const Text('No active loan found')),
                // এই লাইনটি যুক্ত হয়েছে

                const SizedBox(height: 20),

                // যদি hasLoan false হয়, তাহলে LoanTextDetailsWidget দেখানো হবে না
                hasLoan
                    ? const LoanTextDetailsWidget()
                    : const SizedBox.shrink(),

                const SizedBox(height: 20),

                // যদি লোন থাকে, তখন SignatureTableWidget দেখানো হবে
                hasLoan
                    ? SignatureTableWidget(
                        borrowerSignature: borrowerSignature,
                        loanStamp: loanStamp,
                      )
                    : const SizedBox.shrink(),
                // signature টেবিল শুধুমাত্র তখনই দেখাবে যদি লোন থাকে
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoanTableWidget extends StatelessWidget {
  final String borrowerName,
      loanTime,
      loanAmount,
      loanInstallments,
      monthlyInterestRate,
      contactNumber;

  const LoanTableWidget({
    required this.borrowerName,
    required this.loanTime,
    required this.loanAmount,
    required this.loanInstallments,
    required this.monthlyInterestRate,
    required this.contactNumber,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Borrower:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(borrowerName),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Loan Time:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(loanTime),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Contact Number:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(contactNumber),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Loan Amount:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(loanAmount),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Loan Installments:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(loanInstallments),
          ),
        ]),
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Monthly Interest Rate:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(monthlyInterestRate),
          ),
        ]),
      ],
    );
  }
}

class SignatureTableWidget extends StatelessWidget {
  final String borrowerSignature, loanStamp;

  const SignatureTableWidget({
    required this.borrowerSignature,
    required this.loanStamp,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Borrower Signature:'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              borrowerSignature, // Borrower's signature image URL
              height: 100,
            ),
          ),
        ]),
        TableRow(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Loan Stamp:'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              loanStamp, // Loan stamp image URL
              height: 100,
            ),
          ),
        ]),
      ],
    );
  }
}

class LoanTextDetailsWidget extends StatelessWidget {
  const LoanTextDetailsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Payment Method:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Option A: Automatic deduction by the system on the 10th of every month.\n'
                'Option B: Transfer via electronic banking system; bank & Ewallet\n'
                'Option C: Direct bank transaction & NEFT',
          ),
          SizedBox(height: 16),
          Text(
            'Warranty clause:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'The Reserve Bank of India has mandated savings for loans, requiring clients to accumulate savings to avail loans. '
                'The clients\' deposited money will be credited to the wallet along with the loan amount. '
                'After repayment of the loan, the accumulated savings will be returned to the clients. '
                'The savings deposited by the clients for taking the loan will be recorded in the loan agreement form. '
                'The company will be obliged to return the savings to the clients after repayment of the loan.',
          ),
          SizedBox(height: 16),
          Text(
            'Prepayment:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Borrower has the right to pay back the whole exceptional amount at any time. If Borrower pays before time, or if this loan is refinanced or replaced by a new note, '
                'Lender will refund the unearned finance charge, figured by the Rule of 78—a commonly used formula for figuring rebates on installment loans.',
          ),
          SizedBox(height: 16),
          Text(
            'Late Charge:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Any payment not remunerated within ten (10) days of its due date shall be subject to a belated charge of 5% of the payment, not to exceed BDT 10000 for any such late installment.',
          ),
          SizedBox(height: 16),
          Text(
            'Security:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'To protect Lender, the loan company working online different from another bank that\'s why Party A does not require collateral for this loan. '
                'Party A only requires the deposit in advance to verify the repayment ability of customers.',
          ),
          SizedBox(height: 16),
          Text(
            'Wrong Information:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'If Party B provides wrong bank information or ID information, then Party A should ask for a deposit from Party B 20% of the loan amount to solve this problem. '
                'This amount will be refunded to Party B along with the loan amount later.',
          ),
          SizedBox(height: 16),
          Text(
            'Liabilities:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'If Party B is involved in any kind of illegal activities such as gambling, money laundering, etc., then Party A can take legal action or Party B might pay the full loan amount in advance.',
          ),
          SizedBox(height: 16),
          Text(
            'Default:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'If for any reason Borrower does not succeed in making any payment on time, Borrower shall be in default. The Lender can then order instant payment of the entire remaining unpaid balance of this loan, without giving anyone further notices. '
                'If Borrower has not paid the full amount of the loan when the final payment is due, the Lender will charge Borrower interest on the unpaid balance at 6% per year.',
          ),
          SizedBox(height: 16),
          Text(
            'Loan Cancellation:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'If Party B wants to cancel the loan after applying, then Party B is subject to pay 5% of the loan amount for loan cancellation. After cancellation, Party B does not need to pay any loan installment.',
          ),
          SizedBox(height: 16),
          Text(
            'Collection fees:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'If this note is placed with a legal representative for collection, then Borrower agrees to pay an attorney\'s fee of fifteen percent (15%) of the voluntary balance. This fee will be added to the unpaid balance of the loan.',
          ),
          SizedBox(height: 16),
          Text(
            'Rights & Obligations:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'The signed contract has a strong and valid legal force. All parties, both Party A and Party B, must follow all the rules and conditions contained in the contract agreement. '
                'All parties to the contract will strictly carry out their obligations under the credit contract. Both parties are fully responsible for the contents of the agreed contract.',
          ),
          SizedBox(height: 16),
          Text(
            'Co-borrowers:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Any co-borrowers signing this agreement agree to be likewise accountable with the borrower for this loan.',
          ),
        ],
      ),
    );
  }
}
