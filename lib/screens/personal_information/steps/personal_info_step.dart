import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';

class PersonalInfoStepScreen extends StatelessWidget {
  const PersonalInfoStepScreen({Key? key}) : super(key: key);

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  String? validateProfession(String? value) {
    if (value == null || value.isEmpty) {
      return 'Profession is required';
    }
    if (value.length < 3) {
      return 'Please enter a valid profession';
    }
    return null;
  }

  String? validateMonthlyIncome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Monthly income is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter a valid number';
    }
    final income = int.tryParse(value);
    if (income == null || income < 1000) {
      return 'Monthly income must be at least 1,000';
    }
    return null;
  }

  String? validateLoanPurpose(String? value) {
    if (value == null || value.isEmpty) {
      return 'Loan purpose is required';
    }
    if (value.length < 10) {
      return 'Please provide more details about the loan purpose';
    }
    return null;
  }

  String? validateEducation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Education information is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context),
              SizedBox(height: 24),
              _buildTextField(
                context,
                'Full Name',
                provider.nameController,
                prefixIcon: Icons.person_outline,
                validator: validateName,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Current Address',
                provider.currentAddressController,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                validator: validateAddress,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Permanent Address',
                provider.permanentAddressController,
                prefixIcon: Icons.home_outlined,
                maxLines: 2,
                validator: validateAddress,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Profession',
                provider.professionController,
                prefixIcon: Icons.work_outline,
                validator: validateProfession,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Monthly Income',
                provider.monthlyIncomeController,
                prefixIcon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                validator: validateMonthlyIncome,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Purpose of Loan',
                provider.loanPurposeController,
                prefixIcon: Icons.assignment_outlined,
                maxLines: 2,
                validator: validateLoanPurpose,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Education',
                provider.educationController,
                prefixIcon: Icons.school_outlined,
                validator: validateEducation,
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade700, Colors.cyan.shade300],
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
                Icons.info_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Important',
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
            'Please provide accurate personal information. This information will be used to verify your identity and process your loan application.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
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
  }) {
    // Get provider to check if user is verified
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);
    final bool isReadOnly = provider.isVerified;

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
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: isReadOnly,
        enabled: !isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}
