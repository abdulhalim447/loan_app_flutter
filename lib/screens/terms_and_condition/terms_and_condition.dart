import 'package:flutter/material.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms and condtion"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
                style: TextStyle(fontSize: 16, color: Colors.white),
                "•Thanks for staying with us! You can easily take a loan from us at home. You can take a loan from us from 1 lakh to 25 lakh rupees. You have to pay installments to our company bank account between 1st-10th of every month. If you are not able to pay installments in any month then you can pay 2 months installments at once. If it is more than 2 months, you may have to pay a small penalty.\n• Avoid calling/messaging unnecessarily.\n• If you have any complaints or if you have been cheated from elsewhere, you can report to us. We will take strict action against it.\n• Avoid giving wrong information, bank will be obliged to take action if wrong or fake information is given. \n No deposit or advance money to pay or not?\n• You may be required to pay a temporary deposit or transfer fee or be insured to verify your borrowing capacity. You will be refunded after verification of savings or transfer fees, and insurance money will be refunded after payment of installments.\nWhat to do if the account number or personal information is wrong?\n• In case of incorrect account number or personal information, correction fee will be charged.\nWhat to do if you forget the password?\n• Contact our customer representative if you forgot your password.\nHow long can it take to get a loan?\n• How long it takes for your loan to complete is based on your loan amount, but it may take 1-5 days if it is an hourly or larger amount."),
          ),
        ),
      ),
    );
  }
}
