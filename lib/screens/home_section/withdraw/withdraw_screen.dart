import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/withdraw_provider.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure the context is ready for Provider
    Future.microtask(() {
      context.read<WithdrawProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Withdraw",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<WithdrawProvider>(
        builder: (context, withdrawProvider, _) {
          if (withdrawProvider.isUploading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Uploading payment screenshot...",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          if (withdrawProvider.isSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 24),
                  Text(
                    "Payment proof submitted successfully!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "We will process your withdrawal request shortly.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3366FF),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Back to Home"),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => withdrawProvider.fetchWithdrawDetails(),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: 24,
              ),
              children: [
                _buildBalanceCard(withdrawProvider),
                SizedBox(height: 24),
                if (withdrawProvider.message.isNotEmpty)
                  Column(
                    children: [
                      _buildMessageCard(withdrawProvider),
                      SizedBox(height: 16),
                    ],
                  ),
                _buildMobilePaymentOptions(withdrawProvider),
                SizedBox(height: 16),
                _buildFeeCard(withdrawProvider),
                SizedBox(height: 24),
                _buildTransactionUpload(withdrawProvider),
                SizedBox(height: 24),
              ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideX(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(WithdrawProvider provider) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4E54C8),
            Color(0xFF8F94FB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4E54C8).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: provider.isLoading
          ? _buildBalanceCardShimmer()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Withdraw Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 1,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildBalanceItem(
                        "Available Balance", provider.balance, "৳"),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildBalanceItem("Loan Amount", provider.loan, "৳"),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildBalanceCardShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 150,
          color: Colors.white.withOpacity(0.3),
        ),
        SizedBox(height: 16),
        Divider(
          color: Colors.white.withOpacity(0.3),
          thickness: 1,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 24,
                    width: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 24,
                    width: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceItem(String label, String amount, String currency) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currency,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Text(
                amount,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(WithdrawProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFFB74D).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFFF9800)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.message,
              style: TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePaymentOptions(WithdrawProvider provider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: provider.isLoading
          ? _buildMobilePaymentShimmer()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mobile Payment Options",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF3366FF).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentMethodRow(
                        "bKash",
                        provider.bkashNumber,
                        Icons.account_balance_wallet,
                        Color(0xFFE2136E),
                      ),
                      SizedBox(height: 16),
                      _buildPaymentMethodRow(
                        "Nagad",
                        provider.nagadNumber,
                        Icons.account_balance_wallet,
                        Color(0xFFFF6A00),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Please make payment to one of these mobile accounts and upload the screenshot below.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3142).withOpacity(0.7),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMobilePaymentShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 180,
          color: Colors.grey[300],
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF2F8FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFF3366FF).withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              ...List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 60,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 14,
                            width: 120,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 14,
          width: double.infinity,
          color: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodRow(
      String title, String number, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Copy to clipboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title number copied to clipboard'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3142).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.content_copy,
            size: 18,
            color: Color(0xFF3366FF),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionUpload(WithdrawProvider provider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upload Payment Proof",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3142),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () => provider.pickImage(),
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF3366FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: provider.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        provider.image!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Color(0xFF3366FF),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Tap to select a screenshot",
                          style: TextStyle(
                            color: Color(0xFF2D3142),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Upload screenshot of your payment to mobile banking",
                          style: TextStyle(
                            color: Color(0xFF2D3142).withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (provider.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                provider.errorMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                provider.image == null ? null : () => provider.submitImage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3366FF),
              disabledBackgroundColor: Color(0xFF3366FF).withOpacity(0.5),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Submit Payment Proof",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(WithdrawProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF4B4B), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF4B4B).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: Colors.white),
          SizedBox(width: 12),
          Text(
            "Fee: ${provider.fee ?? '0'}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
