import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';
import '../../core/theme/app_theme.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isDisposed = false; // Track if widget is disposed

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
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

    // Set status bar icons to white
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Delay animation slightly to prevent jank during screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed first
    _animationController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    final url = ApiEndpoints.changePassword;

    // Get token
    String? token = await UserSession.getToken();

    if (token == null) {
      if (mounted) {
        _showSnackBar('User not logged in. Please log in again.',
            isError: true);
      }
      return;
    }

    if (!mounted) return; // Safety check if widget was disposed

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'current_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPasswordController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return; // Check again after async operation

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        _showSnackBar('Password changed successfully', isSuccess: true);
        // Reset fields after successful change
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        // Try to parse error message from API
        try {
          var errorData = json.decode(response.body);
          String errorMessage =
              errorData['message'] ?? 'Failed to change password';
          _showSnackBar(errorMessage, isError: true);
        } catch (e) {
          _showSnackBar('Failed to change password', isError: true);
        }
      }
    } catch (e) {
      if (!mounted) return; // Check again
      _showSnackBar('Network error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message,
      {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return; // Don't show snackbar if widget is not mounted

    Color backgroundColor = AppTheme.neutral700;
    if (isError) backgroundColor = Colors.red.shade600;
    if (isSuccess) backgroundColor = Colors.green.shade600;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.authorityBlue,
        centerTitle: true,
        title: Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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

          SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Security message
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.shield,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Security Reminder",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Choose a strong password that you don't use elsewhere.",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Main content card
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Password",
                                    style: TextStyle(
                                      color: AppTheme.neutral800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  _buildPasswordField(
                                    hint: 'Enter your current password',
                                    controller: oldPasswordController,
                                    obscureText: _obscureOldPassword,
                                    toggleObscureText: () {
                                      setState(() {
                                        _obscureOldPassword =
                                            !_obscureOldPassword;
                                      });
                                    },
                                    color: AppTheme.authorityBlue,
                                  ),
                                  SizedBox(height: 24),

                                  Text(
                                    "New Password",
                                    style: TextStyle(
                                      color: AppTheme.neutral800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  _buildPasswordField(
                                    hint: 'Enter your new password',
                                    controller: newPasswordController,
                                    obscureText: _obscureNewPassword,
                                    toggleObscureText: () {
                                      setState(() {
                                        _obscureNewPassword =
                                            !_obscureNewPassword;
                                      });
                                    },
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 20),

                                  Text(
                                    "Confirm New Password",
                                    style: TextStyle(
                                      color: AppTheme.neutral800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  _buildPasswordField(
                                    hint: 'Confirm your new password',
                                    controller: confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    toggleObscureText: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    color: Colors.green,
                                    isConfirmPassword: true,
                                  ),
                                  SizedBox(height: 32),

                                  _buildSaveButton(),

                                  SizedBox(height: 16),

                                  // Password guidelines
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.neutral200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Password Guidelines",
                                          style: TextStyle(
                                            color: AppTheme.neutral800,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        _buildGuideline(
                                            "At least 8 characters long"),
                                        SizedBox(height: 4),
                                        _buildGuideline(
                                            "Contains uppercase and lowercase letters"),
                                        SizedBox(height: 4),
                                        _buildGuideline(
                                            "Contains at least one number"),
                                        SizedBox(height: 4),
                                        _buildGuideline(
                                            "Contains at least one special character"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Colors.green.shade600,
          size: 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.neutral700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscureText,
    required Color color,
    bool isConfirmPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.neutral800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppTheme.neutral500,
          fontSize: 15,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: color,
            size: 22,
          ),
          onPressed: toggleObscureText,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }

        if (isConfirmPassword && value != newPasswordController.text) {
          return 'Passwords do not match';
        }

        if (!isConfirmPassword && controller == newPasswordController) {
          // Validate password strength
          if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
        }

        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                if (_formKey.currentState?.validate() ?? false) {
                  _changePassword(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.authorityBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          shadowColor: AppTheme.authorityBlue.withOpacity(0.4),
          disabledBackgroundColor: AppTheme.neutral400,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Updating...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                "Update Password",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
