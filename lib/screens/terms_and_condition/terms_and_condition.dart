import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar icons to white for better visibility with gradient background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: SafeArea(
        // Use SafeArea to avoid system UI elements
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatefulWidget {
  @override
  _TermsContentState createState() => _TermsContentState();
}

class _TermsContentState extends State<_TermsContent> {
  // Safe dispose flag
  bool _isDisposed = false;
  // Scroll controller to enable features like scroll to top
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Modern gradient background
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade800,
            Colors.blue.shade600,
            Colors.blue.shade400,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            // Expanded to take remaining space
            child: _buildContentCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (!_isDisposed) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          // Title
          const Text(
            "Terms and Conditions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    try {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                "Loan Terms",
                [
                  "Thanks for staying with us! You can easily take a loan from us at home.",
                  "You can take a loan from us from 1 lakh to 25 lakh rupees.",
                  "You have to pay installments to our company bank account between 1st-10th of every month.",
                  "If you are not able to pay installments in any month then you can pay 2 months installments at once.",
                  "If it is more than 2 months, you may have to pay a small penalty.",
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                "Communication Policy",
                [
                  "Avoid calling/messaging unnecessarily.",
                  "If you have any complaints or if you have been cheated from elsewhere, you can report to us. We will take strict action against it.",
                  "Avoid giving wrong information, bank will be obliged to take action if wrong or fake information is given.",
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                "Deposits and Fees",
                [
                  "You may be required to pay a temporary deposit or transfer fee or be insured to verify your borrowing capacity.",
                  "You will be refunded after verification of savings or transfer fees, and insurance money will be refunded after payment of installments.",
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                "Account Issues",
                [
                  "In case of incorrect account number or personal information, correction fee will be charged.",
                  "Contact our customer representative if you forgot your password.",
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                "Loan Processing Time",
                [
                  "How long it takes for your loan to complete is based on your loan amount, but it may take 1-5 days if it is an hourly or larger amount.",
                ],
              ),
              const SizedBox(height: 32),
              _buildAcceptanceNote(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    } catch (e) {
      // Fallback in case of rendering error
      if (_isDisposed) return Container();

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            "An error occurred while loading terms. Please try again later.",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => _buildBulletPoint(point)),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Text(
            "By using our services, you agree to these terms and conditions.",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Last updated: ${_getFormattedDate()}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    try {
      final now = DateTime.now();
      return "${now.day}/${now.month}/${now.year}";
    } catch (e) {
      return "2023";
    }
  }
}
