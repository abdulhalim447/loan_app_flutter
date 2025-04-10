import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/screens/home_section/home_page.dart';
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';
import '../../slider/home_screen_slider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_endpoints.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  _LoanApplicationScreenState createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen>
    with SingleTickerProviderStateMixin {
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
    2500000,
    3000000,
  ];
  final List<int> loanTerms = [12, 18, 24, 36, 48, 60];
  final double interestRate = 0.3;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int selectedLoanAmount = 0;
  int selectedLoanTerm = 12;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Set status bar icons to white
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Installment calculation function
  double calculateInstallment(int loanAmount, int term) {
    double totalInterest = loanAmount * interestRate / 100 * term / 12;
    double totalAmount = loanAmount + totalInterest;
    return totalAmount / term;
  }

  // API submit function
  Future<void> submitLoanApplication() async {
    setState(() => isLoading = true);

    String? token = await UserSession.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User token not found!')));
      setState(() => isLoading = false);
      return;
    }

    final apiUrl = ApiEndpoints.loans;
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Loan application submitted successfully'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit loan application'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
    setState(() => isLoading = false);
  }

  // UI build
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Loan Application',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: AppTheme.authorityBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.authorityBlue,
                  AppTheme.trustCyan,
                  AppTheme.backgroundLight,
                ],
                stops: [0.0, 0.2, 0.4],
              ),
            ),
          ),

          isLoading
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.authorityBlue),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Processing your application...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Banner slider
                              SizedBox(
                                height: screenSize.height * 0.22,
                                child: HomeBannerSlider(),
                              ),

                              // Loan Details Card
                              Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Loan Details",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.authorityBlue,
                                            fontSize: 15,
                                          ),
                                    ),
                                    SizedBox(height: 12),
                                    // New row containing total amount paid and total installments
                                    Row(
                                      children: [
                                        // Total Amount Paid
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .authorityBlue
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .account_balance_wallet,
                                                        color: AppTheme
                                                            .authorityBlue,
                                                        size: 14,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      "Total Repayment",
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  selectedLoanAmount > 0 ? (selectedLoanAmount + (selectedLoanAmount * interestRate / 100 * selectedLoanTerm / 12)).toStringAsFixed(0) : '0',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Total Installments
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .trustCyan
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color:
                                                            AppTheme.trustCyan,
                                                        size: 14,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      "Installments",
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "$selectedLoanTerm months",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Monthly payment overview
                                    if (selectedLoanAmount > 0)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.grey.shade600,
                                              size: 14,
                                            ),
                                            SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                "Your monthly payment will be ${calculateInstallment(selectedLoanAmount, selectedLoanTerm).toStringAsFixed(0)} for $selectedLoanTerm months",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Select Loan Term
                              Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Select Loan Term",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.authorityBlue,
                                          ),
                                    ),
                                    SizedBox(height: 12),
                                    // Term selection grid - two rows with three tiles
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: loanTerms.length,
                                      itemBuilder: (context, index) {
                                        bool isSelected = selectedLoanTerm ==
                                            loanTerms[index];
                                        return GestureDetector(
                                          onTap: () => setState(() {
                                            selectedLoanTerm = loanTerms[index];
                                            selectedLoanAmount = 0;
                                          }),
                                          child: TermSelectionCard(
                                            term: loanTerms[index],
                                            isSelected: isSelected,
                                            animationController:
                                                _animationController,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Select Loan Amount
                              Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Select Loan Amount",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.authorityBlue,
                                          ),
                                    ),
                                    SizedBox(height: 12),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: loanAmounts.length,
                                      itemBuilder: (context, index) {
                                        double installment =
                                            calculateInstallment(
                                                loanAmounts[index],
                                                selectedLoanTerm);
                                        bool isSelected = selectedLoanAmount ==
                                            loanAmounts[index];

                                        return GestureDetector(
                                          onTap: () => setState(() {
                                            selectedLoanAmount =
                                                loanAmounts[index];
                                          }),
                                          child: AmountSelectionCard(
                                            amount: loanAmounts[index],
                                            installment: installment,
                                            isSelected: isSelected,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Loan Information Section
                              Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.neutral200,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Loan Information",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.authorityBlue,
                                          ),
                                    ),
                                    SizedBox(height: 12),

                                    // Interest Rate Info
                                    Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.trustCyan
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.percent_rounded,
                                              color: AppTheme.authorityBlue,
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Interest Rate",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppTheme.neutral800,
                                                      ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  "$interestRate% per annum (fixed)",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            AppTheme.neutral700,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Processing Time Info
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.success
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.access_time_filled_rounded,
                                              color: AppTheme.success,
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Fast Processing",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppTheme.neutral800,
                                                      ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  "Applications are typically approved within 24 hours",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            AppTheme.neutral700,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Submit Application Button
                              Container(
                                margin: EdgeInsets.all(16),
                                child: ElevatedButton(
                                  onPressed: selectedLoanAmount > 0
                                      ? submitLoanApplication
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.authorityBlue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 5,
                                    shadowColor: selectedLoanAmount > 0
                                        ? AppTheme.authorityBlue
                                            .withOpacity(0.4)
                                        : Colors.transparent,
                                    disabledBackgroundColor:
                                        AppTheme.neutral300,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Submit Application',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class TermSelectionCard extends StatefulWidget {
  final int term;
  final bool isSelected;
  final AnimationController animationController;

  const TermSelectionCard({
    super.key,
    required this.term,
    required this.isSelected,
    required this.animationController,
  });

  @override
  _TermSelectionCardState createState() => _TermSelectionCardState();
}

class _TermSelectionCardState extends State<TermSelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shineController,
        curve: Curves.easeInOut,
      ),
    );

    _shineController.repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: widget.isSelected ? AppTheme.authorityBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? AppTheme.authorityBlue.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (widget.isSelected)
            AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Transform.translate(
                      offset: Offset(
                        _shineAnimation.value *
                            MediaQuery.of(context).size.width,
                        0,
                      ),
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.term}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.isSelected
                            ? Colors.white
                            : AppTheme.authorityBlue,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  "months",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.isSelected
                            ? Colors.white70
                            : AppTheme.neutral600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AmountSelectionCard extends StatefulWidget {
  final int amount;
  final double installment;
  final bool isSelected;

  const AmountSelectionCard({
    super.key,
    required this.amount,
    required this.installment,
    required this.isSelected,
  });

  @override
  _AmountSelectionCardState createState() => _AmountSelectionCardState();
}

class _AmountSelectionCardState extends State<AmountSelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shineController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isSelected) {
      _shineController.repeat();
    }
  }

  @override
  void didUpdateWidget(AmountSelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _shineController.repeat();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _shineController.stop();
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive text sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final amountFontSize = screenWidth < 360 ? 14.0 : 16.0;
    final installmentFontSize = screenWidth < 360 ? 14.0 : 16.0;
    final labelFontSize = screenWidth < 360 ? 10.0 : 12.0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isSelected ? AppTheme.authorityBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              widget.isSelected ? AppTheme.authorityBlue : AppTheme.neutral200,
          width: 1,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: AppTheme.authorityBlue.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          if (widget.isSelected)
            AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Transform.translate(
                      offset: Offset(
                        _shineAnimation.value *
                            MediaQuery.of(context).size.width,
                        0,
                      ),
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.monetization_on,
                  color:
                      widget.isSelected ? Colors.white : AppTheme.authorityBlue,
                  size: 18,
                ),
              ),
              SizedBox(width: 10),
              Text(
                '${widget.amount}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: amountFontSize,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected
                          ? Colors.white
                          : AppTheme.authorityBlue,
                    ),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Monthly Installment',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: labelFontSize,
                          color: widget.isSelected
                              ? Colors.white70
                              : AppTheme.neutral600,
                        ),
                  ),
                  Text(
                    widget.installment.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: installmentFontSize,
                          fontWeight: FontWeight.bold,
                          color: widget.isSelected
                              ? Colors.white
                              : AppTheme.authorityBlue,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
