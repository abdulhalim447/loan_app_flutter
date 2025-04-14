import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';

class BankAccountStepScreen extends StatefulWidget {
  const BankAccountStepScreen({super.key});

  @override
  _BankAccountStepScreenState createState() => _BankAccountStepScreenState();
}

class _BankAccountStepScreenState extends State<BankAccountStepScreen> {
  // Add a state variable to track whether bank details are visible
  bool _showBankDetails = false;

  String? validateAccountHolder(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account holder name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateBankName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bank name is required';
    }
    if (value.length < 3) {
      return 'Please enter a valid bank name';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Bank name can only contain letters and spaces';
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    // Remove any spaces or special characters
    String cleanAccount = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{9,18}$').hasMatch(cleanAccount)) {
      return 'Please enter a valid account number (9-18 digits)';
    }
    return null;
  }

  String? validateBranchName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Branch name is required';
    }
    if (value.length < 2) {
      return 'Please enter a valid branch name';
    }
    return null;
  }

  // Helper method to mask sensitive information
  String maskSensitiveInfo(String text, {bool keepEnds = true}) {
    if (text.isEmpty) return '';
    if (text.length <= 4) return '*' * text.length;

    if (keepEnds) {
      return text.substring(0, 2) +
          '*' * (text.length - 4) +
          text.substring(text.length - 2);
    } else {
      return '*' * text.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        bool isVerified = provider.isVerified;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context),
                SizedBox(height: 24),

                // Show toggle button only if user is verified
                // This ensures the button only appears after verification
                if (isVerified && _hasValidBankDetails(provider))
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showBankDetails = !_showBankDetails;
                        });
                      },
                      icon: Icon(_showBankDetails
                          ? Icons.visibility_off
                          : Icons.visibility),
                      label: Text(_showBankDetails
                          ? 'Hide Bank Details'
                          : 'Show Bank Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                _buildTextField(
                  context,
                  'Account Holder Name',
                  provider.accountHolderController,
                  prefixIcon: Icons.person_outline,
                  validator: validateAccountHolder,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  context,
                  'Bank Name',
                  provider.bankNameController,
                  prefixIcon: Icons.account_balance_outlined,
                  validator: validateBankName,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  context,
                  'Account Number',
                  provider.accountNumberController,
                  prefixIcon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  validator: validateAccountNumber,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  context,
                  'Branch Name',
                  provider.ifcCodeController,
                  prefixIcon: Icons.business_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: validateBranchName,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 24),
                _buildSecurityNotice(context),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    bool isHidden = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    // If the field should be hidden, create a masked value
    String displayValue = '';
    if (isHidden) {
      // Different masking for different field types
      if (label == 'Account Number') {
        displayValue = maskSensitiveInfo(controller.text, keepEnds: true);
      } else {
        displayValue = maskSensitiveInfo(controller.text, keepEnds: false);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isHidden
          ? _buildMaskedField(context, label, displayValue, prefixIcon)
          : TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              readOnly: isReadOnly,
              enabled: !isReadOnly,
              textCapitalization: textCapitalization,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                errorStyle: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                ),
                suffix: isReadOnly
                    ? Icon(Icons.lock, size: 16, color: Colors.grey)
                    : null,
              ),
              onChanged: (value) {
                if (!isReadOnly) {
                  Provider.of<PersonalInfoProvider>(context, listen: false)
                      .saveData();
                }
              },
              validator: isReadOnly ? null : validator,
              autovalidateMode: isReadOnly
                  ? AutovalidateMode.disabled
                  : AutovalidateMode.onUserInteraction,
            ),
    );
  }

  // New widget for displaying masked fields
  Widget _buildMaskedField(
    BuildContext context,
    String label,
    String maskedValue,
    IconData? prefixIcon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: Colors.grey),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  maskedValue,
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'HIDDEN',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Bank Account Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Please provide your bank account details. This is where we will disburse your loan amount.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Security Notice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your bank details are secured with bank-level encryption',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We will only use this information to disburse your loan amount',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please verify the details before submitting to avoid delays',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasValidBankDetails(PersonalInfoProvider provider) {
    // Implement the logic to check if there's valid bank details
    // This is a placeholder and should be replaced with the actual implementation
    return provider.accountHolderController.text.isNotEmpty &&
        provider.bankNameController.text.isNotEmpty &&
        provider.accountNumberController.text.isNotEmpty &&
        provider.ifcCodeController.text.isNotEmpty;
  }
}
