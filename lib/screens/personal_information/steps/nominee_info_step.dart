import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';

class NomineeInfoStepScreen extends StatelessWidget {
  const NomineeInfoStepScreen({super.key});

  String? validateNomineeName(String? value) {
    if (value == null || value.isEmpty) {
      return 'মনোনীত ব্যক্তির নাম আবশ্যক';
    }
    if (value.length < 3) {
      return 'নাম কমপক্ষে ৩ অক্ষর হতে হবে';
    }
    
    return null;
  }

  String? validateNomineeRelation(String? value) {
    if (value == null || value.isEmpty) {
      return 'মনোনীত ব্যক্তির সাথে সম্পর্ক আবশ্যক';
    }
    if (value.length < 3) {
      return 'দয়া করে একটি বৈধ সম্পর্ক উল্লেখ করুন';
    }
    
    return null;
  }

  String? validateNomineePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'মনোনীত ব্যক্তির ফোন নম্বর আবশ্যক';
    }
    // Remove any spaces or special characters
    String cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\d{10,12}$').hasMatch(cleanPhone)) {
      return 'দয়া করে একটি বৈধ ফোন নম্বর লিখুন (১০-১২ ডিজিট)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        bool isVerified = provider.isVerified;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context),
              SizedBox(height: 24),
              _buildTextField(
                context,
                'মনোনীত ব্যক্তির নাম',
                provider.nomineeNameController,
                prefixIcon: Icons.person_outline,
                validator: validateNomineeName,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'মনোনীত ব্যক্তির সাথে সম্পর্ক',
                provider.nomineeRelationController,
                prefixIcon: Icons.people_outline,
                validator: validateNomineeRelation,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'মনোনীত ব্যক্তির ফোন নম্বর',
                provider.nomineePhoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: validateNomineePhone,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 24),
              _buildNomineeExplanation(context),
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
          colors: [Colors.purple.shade700, Colors.purple.shade300],
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
                Icons.people_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'মনোনীত ব্যক্তির তথ্য',
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
            'মনোনীত ব্যক্তি হলেন সেই ব্যক্তি যার কোনো অপ্রত্যাশিত পরিস্থিতিতে আপনার ঋণ অ্যাকাউন্টের অধিকার থাকবে।',
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
    bool isReadOnly = false,
  }) {
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

  Widget _buildNomineeExplanation(BuildContext context) {
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
          Text(
            'কেন কাউকে মনোনীত করবেন?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.purple.shade700, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'প্রয়োজনে আপনার প্রিয়জনদের আপনার অ্যাকাউন্ট অ্যাক্সেস করতে পারবেন',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.purple.shade700, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'জরুরি অবস্থায় অর্থ স্থানান্তর প্রক্রিয়া সহজ করে',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.purple.shade700, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'আমাদের নীতি অনুসারে ঋণ অনুমোদনের জন্য প্রয়োজনীয়',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
