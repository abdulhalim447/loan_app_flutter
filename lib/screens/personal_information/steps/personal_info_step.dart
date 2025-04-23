import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';

class PersonalInfoStepScreen extends StatelessWidget {
  const PersonalInfoStepScreen({super.key});

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'নাম আবশ্যক';
    }
    if (value.length < 3) {
      return 'নাম কমপক্ষে ৩ অক্ষর হতে হবে';
    }

    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'ঠিকানা আবশ্যক';
    }
    if (value.length < 5) {
      return 'দয়া করে সম্পূর্ণ ঠিকানা লিখুন';
    }
    return null;
  }

  String? validateProfession(String? value) {
    if (value == null || value.isEmpty) {
      return 'পেশা আবশ্যক';
    }
    if (value.length < 3) {
      return 'দয়া করে একটি বৈধ পেশা লিখুন';
    }
    return null;
  }

  String? validateMonthlyIncome(String? value) {
    if (value == null || value.isEmpty) {
      return 'মাসিক আয় আবশ্যক';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'দয়া করে একটি বৈধ সংখ্যা লিখুন';
    }
    final income = int.tryParse(value);
    if (income == null || income < 1000) {
      return 'মাসিক আয় কমপক্ষে ১,০০০ হতে হবে';
    }
    return null;
  }

  String? validateLoanPurpose(String? value) {
    if (value == null || value.isEmpty) {
      return 'ঋণের উদ্দেশ্য আবশ্যক';
    }
    if (value.length < 5) {
      return 'দয়া করে ঋণের উদ্দেশ্য সম্পর্কে আরও বিস্তারিত প্রদান করুন';
    }
    return null;
  }

  String? validateEducation(String? value) {
    if (value == null || value.isEmpty) {
      return 'শিক্ষাগত তথ্য আবশ্যক';
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
                'পূর্ণ নাম',
                provider.nameController,
                prefixIcon: Icons.person_outline,
                validator: validateName,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'ঠিকানা',
                provider.currentAddressController,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                validator: validateAddress,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'পেশা',
                provider.professionController,
                prefixIcon: Icons.work_outline,
                validator: validateProfession,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'মাসিক আয়',
                provider.monthlyIncomeController,
                prefixIcon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                validator: validateMonthlyIncome,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'ঋণের উদ্দেশ্য',
                provider.loanPurposeController,
                prefixIcon: Icons.assignment_outlined,
                maxLines: 2,
                validator: validateLoanPurpose,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'শিক্ষাগত যোগ্যতা',
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
                'গুরুত্বপূর্ণ',
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
            'অনুগ্রহ করে সঠিক ব্যক্তিগত তথ্য প্রদান করুন। এই তথ্য আপনার পরিচয় যাচাই করতে এবং আপনার ঋণের আবেদন প্রক্রিয়া করতে ব্যবহার করা হবে।',
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
