import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/auth/LoginScreen.dart';
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:world_bank_loan/bottom_navigation/MainNavigationScreen.dart';
import 'package:world_bank_loan/core/theme/fintech_theme.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  String countryCode = "+880";
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
    confirmPasswordVisible = false;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      confirmPasswordVisible = !confirmPasswordVisible;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'নাম প্রয়োজন';
    }
    if (value.length < 2) {
      return 'নাম কমপক্ষে ২ অক্ষরের হতে হবে';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'ফোন নম্বর প্রয়োজন';
    }
    if (value.length < 5) {
      return 'একটি বৈধ ফোন নম্বর দিন';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'পাসওয়ার্ড প্রয়োজন';
    }
    if (value.length < 6) {
      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'আপনার পাসওয়ার্ড নিশ্চিত করুন';
    }
    if (value != passwordController.text) {
      return 'পাসওয়ার্ড মিলছে না';
    }
    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': phoneController.text.trim(),
          'countryCode': countryCode,
          'password': passwordController.text.trim(),
          'c_password': confirmPasswordController.text.trim(),
          'name': nameController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Get token from the registration response
          String token = responseData['token'] ?? '';

          if (token.isNotEmpty) {
            // Save the session data
            await UserSession.saveSession(token, phoneController.text.trim());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('নিবন্ধন সফল! আপনাকে লগ ইন করা হচ্ছে...'),
                backgroundColor: FintechTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(FintechTheme.borderRadius),
                ),
              ),
            );

            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MainNavigationScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: Duration(milliseconds: 500),
                ),
              );
            });
          } else {
            // If token is not available in response, proceed with normal login
            _automaticLogin();
          }
        } else {
          _showErrorDialog(responseData['message'] ?? 'Registration failed');
        }
      } else {
        _showErrorDialog('Failed to register. Please try again later.');
      }
    } catch (error) {
      if (!mounted) return;
      _showErrorDialog(
          'An error occurred. Please check your connection and try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // New method to automatically login after registration if token is not provided
  Future<void> _automaticLogin() async {
    try {
      final loginResponse = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'countryCode': countryCode,
          'phone': phoneController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (loginResponse.statusCode == 200) {
        final Map<String, dynamic> loginData = json.decode(loginResponse.body);

        if (loginData['success'] != null && loginData['success']) {
          // Save token and phone after successful login
          String token = loginData['token'];
          await UserSession.saveSession(token, phoneController.text.trim());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('নিবন্ধন সফল! আপনার অ্যাকাউন্টে স্বাগতম।'),
              backgroundColor: FintechTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FintechTheme.borderRadius),
              ),
            ),
          );

          // Navigate to the main screen
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MainNavigationScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          });
        } else {
          // If automatic login fails, redirect to login screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('নিবন্ধন সফল! অনুগ্রহ করে লগইন করুন।'),
              backgroundColor: FintechTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FintechTheme.borderRadius),
              ),
            ),
          );

          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          });
        }
      } else {
        // If automatic login fails, redirect to login screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('নিবন্ধন সফল! অনুগ্রহ করে লগইন করুন।'),
            backgroundColor: FintechTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FintechTheme.borderRadius),
            ),
          ),
        );

        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: Duration(milliseconds: 500),
            ),
          );
        });
      }
    } catch (error) {
      // If automatic login fails with exception, redirect to login screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('নিবন্ধন সফল! অনুগ্রহ করে লগইন করুন।'),
          backgroundColor: FintechTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FintechTheme.borderRadius),
          ),
        ),
      );

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FintechTheme.borderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: FintechTheme.error),
            SizedBox(width: 8),
            Text('ত্রুটি', style: TextStyle(color: FintechTheme.error)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2C3E50),
                    Color(0xFF3498DB),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 1000.ms)
                .shimmer(duration: 2000.ms, delay: 1000.ms),
          ),

          // Animated Circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .scaleXY(
                  duration: 3000.ms,
                  curve: Curves.easeInOut,
                ),
          ),

          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .scaleXY(
                  duration: 3000.ms,
                  curve: Curves.easeInOut,
                ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    _buildWelcomeText(),
                    SizedBox(height: 30),
                    // Main Card with Animation
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNameInput()
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 500.ms)
                                  .slide(
                                    begin: Offset(-0.2, 0),
                                    end: Offset.zero,
                                    duration: 500.ms,
                                    curve: Curves.easeOut,
                                  ),
                              SizedBox(height: 24),
                              _buildPhoneInput()
                                  .animate()
                                  .fadeIn(delay: 400.ms, duration: 500.ms)
                                  .slide(
                                    begin: Offset(-0.2, 0),
                                    end: Offset.zero,
                                    duration: 500.ms,
                                    curve: Curves.easeOut,
                                  ),
                              SizedBox(height: 24),
                              _buildPasswordInput()
                                  .animate()
                                  .fadeIn(delay: 600.ms, duration: 500.ms)
                                  .slide(
                                    begin: Offset(-0.2, 0),
                                    end: Offset.zero,
                                    duration: 500.ms,
                                    curve: Curves.easeOut,
                                  ),
                              SizedBox(height: 24),
                              _buildConfirmPasswordInput()
                                  .animate()
                                  .fadeIn(delay: 800.ms, duration: 500.ms)
                                  .slide(
                                    begin: Offset(-0.2, 0),
                                    end: Offset.zero,
                                    duration: 500.ms,
                                    curve: Curves.easeOut,
                                  ),
                              SizedBox(height: 32),
                              _buildSignupButton()
                                  .animate()
                                  .fadeIn(delay: 1000.ms, duration: 500.ms)
                                  .scaleXY(
                                      begin: 0.8,
                                      end: 1,
                                      duration: 500.ms,
                                      curve: Curves.easeOut),
                              SizedBox(height: 24),
                              _buildLoginLink()
                                  .animate()
                                  .fadeIn(delay: 1200.ms, duration: 500.ms)
                                  .slide(
                                    begin: Offset(0, 0.2),
                                    end: Offset.zero,
                                    duration: 500.ms,
                                    curve: Curves.easeOut,
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slide(
                          begin: Offset(0, 0.3),
                          end: Offset.zero,
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: Color(0xFF2C3E50),
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .scaleXY(
              begin: 1,
              end: 1.1,
              duration: 2000.ms,
              curve: Curves.easeInOut,
            )
            .shimmer(duration: 2000.ms, delay: 1000.ms),
        SizedBox(height: 24),
        Text(
          'অ্যাকাউন্ট তৈরি করুন',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slide(
              begin: Offset(0, 0.3),
              end: Offset.zero,
              duration: 600.ms,
              curve: Curves.easeOut,
            )
            .shimmer(duration: 1200.ms, delay: 600.ms),
        SizedBox(height: 12),
        Text(
          'আপনার আর্থিক যাত্রা শুরু করতে আমাদের সাথে যোগ দিন',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slide(
              begin: Offset(0, 0.3),
              end: Offset.zero,
              duration: 800.ms,
              curve: Curves.easeOut,
            ),
      ],
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'পুরো নাম',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          validator: _validateName,
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'আপনার পুরো নাম লিখুন',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon:
                Icon(Icons.person_outline, color: Color(0xFF3498DB), size: 22),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFF3498DB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ফোন নম্বর',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 90),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: CountryCodePicker(
                onChanged: (country) {
                  setState(() {
                    countryCode = country.dialCode ?? "+880";
                  });
                },
                initialSelection: 'BD',
                favorite: ['+880', 'BD'],
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
                padding: EdgeInsets.zero,
                textStyle: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                ),
                flagWidth: 24,
                showFlag: true,
                showFlagDialog: true,
                showDropDownButton: false,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'ফোন নম্বর লিখুন',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Color(0xFF3498DB), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade300),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade300),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'পাসওয়ার্ড',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: !passwordVisible,
          validator: _validatePassword,
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'আপনার পাসওয়ার্ড লিখুন',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon:
                Icon(Icons.lock_outline, color: Color(0xFF3498DB), size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade400,
                size: 22,
              ),
              onPressed: togglePasswordVisibility,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFF3498DB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'পাসওয়ার্ড নিশ্চিত করুন',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: !confirmPasswordVisible,
          validator: _validateConfirmPassword,
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'আপনার পাসওয়ার্ড নিশ্চিত করুন',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon:
                Icon(Icons.lock_outline, color: Color(0xFF3498DB), size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                confirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey.shade400,
                size: 22,
              ),
              onPressed: toggleConfirmPasswordVisibility,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFF3498DB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF3498DB),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading
              ? null
              : () {
                  // Add button press animation
                  if (!isLoading) {
                    _signup();
                  }
                },
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .rotate(
                          duration: 1500.ms,
                          curve: Curves.linear,
                        ),
                  )
                : Text(
                    'নিবন্ধন',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withOpacity(0.8),
                    ),
          ),
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scaleXY(
          begin: 1,
          end: 1.02,
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: Duration(milliseconds: 300),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size(0, 36),
          ),
          child: Text(
            'লগইন',
            style: TextStyle(
              color: Color(0xFF3498DB),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
