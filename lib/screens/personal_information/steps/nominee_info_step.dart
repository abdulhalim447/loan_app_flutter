import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';

class NomineeInfoStepScreen extends StatelessWidget {
  const NomineeInfoStepScreen({super.key});

  String? validateNomineeName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nominee name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateNomineeRelation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Relationship with nominee is required';
    }
    if (value.length < 3) {
      return 'Please specify a valid relationship';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Relationship can only contain letters and spaces';
    }
    return null;
  }

  String? validateNomineePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nominee phone number is required';
    }
    // Remove any spaces or special characters
    String cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\d{10,12}$').hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number (10-12 digits)';
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
                'Nominee Name',
                provider.nomineeNameController,
                prefixIcon: Icons.person_outline,
                validator: validateNomineeName,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Relationship with Nominee',
                provider.nomineeRelationController,
                prefixIcon: Icons.people_outline,
                validator: validateNomineeRelation,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'Nominee Phone Number',
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
                'Nominee Information',
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
            'A nominee is the person who will have the right to your loan account in case of any unforeseen circumstances.',
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
            'Why nominate someone?',
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
                  'Ensures your loved ones can access your account if needed',
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
                  'Simplifies the fund transfer process in emergency situations',
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
                  'Required for loan approval as per our policy',
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
