import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';
import 'multi_step_form.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _needsInitialization = true;

  @override
  void initState() {
    super.initState();
    // We'll initialize in the build method instead
  }

  Future<void> _initializeProvider(PersonalInfoProvider provider) async {
    if (!_needsInitialization) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (provider.currentStep == PersonalInfoStep.personalInfo &&
          !provider.personalInfoCompleted) {
        await provider.initialize();
      }

      _needsInitialization = false;
    } catch (e) {
      debugPrint("PersonalInfoScreen initialization error: $e");
      setState(() {
        _errorMessage = "Failed to initialize: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStepTitle(PersonalInfoStep step) {
    switch (step) {
      case PersonalInfoStep.personalInfo:
        return 'Personal Information';
      case PersonalInfoStep.nomineeInfo:
        return 'Nominee Information';
      case PersonalInfoStep.idVerification:
        return 'ID Verification';
      case PersonalInfoStep.bankAccount:
        return 'Bank Account';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get provider here safely, not in initState
    final provider = Provider.of<PersonalInfoProvider>(context);

    // Initialize provider on first build if needed
    if (_needsInitialization) {
      // Use a post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeProvider(provider);
      });
    }

    Widget content;
    if (_isLoading) {
      content = Center(
        child: CircularProgressIndicator(
          color: Colors.cyan,
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                "Something went wrong",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _needsInitialization = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else {
      content = MultiStepPersonalInfoForm();
    }

    return Scaffold(
      body: SafeArea(child: content),
    );
  }
}
