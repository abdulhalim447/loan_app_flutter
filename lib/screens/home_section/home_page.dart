import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:world_bank_loan/core/theme/app_theme.dart';
import 'package:world_bank_loan/core/widgets/custom_button.dart';
import 'package:world_bank_loan/core/widgets/data_card.dart';
import 'package:world_bank_loan/providers/home_provider.dart';
import 'package:world_bank_loan/screens/home_section/withdraw/withdraw_screen.dart';
import 'package:world_bank_loan/screens/loan_apply_screen/loan_apply_screen.dart';
import 'package:world_bank_loan/screens/personal_information/personal_information.dart';
import 'package:world_bank_loan/slider/home_screen_slider.dart';
import 'package:world_bank_loan/screens/help_section/help_screen.dart';
import 'package:world_bank_loan/screens/notifications/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  final ValueNotifier<bool> _isBalanceVisible = ValueNotifier<bool>(false);
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _scrollController = ScrollController();

    // Use Future.microtask to ensure the context is ready for Provider
    Future.microtask(() {
      context.read<HomeProvider>().initialize();

      // Set up periodic refresh timer - using 3 seconds instead of 1 second
      // to balance between real-time updates and resource usage
      _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (mounted) {
          context.read<HomeProvider>().fetchUserData(silent: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _isBalanceVisible.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Pull to refresh function
  Future<void> _onRefresh() async {
    await context.read<HomeProvider>().fetchUserData();
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ওয়ার্ল্ড ব্যাংক',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        centerTitle: true,
        leading: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildProfileAvatar(provider),
            );
          },
        ),
        actions: [
          Consumer<HomeProvider>(
            builder: (context, provider, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.notifications_outlined, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (provider.unreadNotifications > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          provider.unreadNotifications > 9
                              ? '9+'
                              : provider.unreadNotifications.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.authorityBlue,
        backgroundColor: Colors.white,
        child: Consumer<HomeProvider>(builder: (context, homeProvider, _) {
          // Start animations when data is loaded
          if (!homeProvider.isLoading &&
              homeProvider.loadingStatus == HomeLoadingStatus.loaded) {
            _animationController.forward();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),

                        // Greeting section
                        Text(
                          'হ্যালো,',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.neutral600,
                                  ),
                        )
                            .animate(controller: _animationController)
                            .fadeIn(duration: 500.ms, delay: 100.ms)
                            .slide(
                                begin: Offset(0, -0.2),
                                duration: 500.ms,
                                delay: 100.ms),
                        Text(
                          homeProvider.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        )
                            .animate(controller: _animationController)
                            .fadeIn(duration: 500.ms, delay: 200.ms)
                            .slide(
                                begin: Offset(0, -0.2),
                                duration: 500.ms,
                                delay: 200.ms),

                        SizedBox(height: 24),

                        // Content area
                        // Balance Card
                        _buildBalanceCard(homeProvider)
                            .animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slide(
                                begin: Offset(0, 0.2),
                                duration: 600.ms,
                                delay: 300.ms),

                        SizedBox(height: 24),

                        // Loan progress
                        _buildLoanProgress(homeProvider)
                            .animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 400.ms)
                            .slide(
                                begin: Offset(0, 0.2),
                                duration: 600.ms,
                                delay: 400.ms),

                        SizedBox(height: 24),

                        // Banner slider
                        HomeBannerSlider()
                            .animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slide(
                                begin: Offset(0, 0.2),
                                duration: 600.ms,
                                delay: 500.ms),

                        SizedBox(height: 24),

                        // Section Title
                        Text(
                          'দ্রুত কার্যক্রম',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        )
                            .animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 600.ms)
                            .slide(
                                begin: Offset(0, 0.2),
                                duration: 600.ms,
                                delay: 600.ms),

                        SizedBox(height: 16),

                        // Quick Action Grid
                        _buildQuickActionGrid(homeProvider)
                            .animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 700.ms)
                            .slide(
                                begin: Offset(0, 0.2),
                                duration: 600.ms,
                                delay: 700.ms),
                        SizedBox(height: 24),
//==============================================================================
                        // Loan Application or Status Section
                        _buildLoanApplicationSection(homeProvider)
                            .animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, delay: 800.ms)
                            .slide(
                                begin: Offset(0, 0.2),
                                duration: 600.ms,
                                delay: 800.ms),

                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildBalanceCard(HomeProvider homeProvider) {
    return homeProvider.isLoading
        ? _buildShimmerBalanceCard()
        : DataCard(
            title: 'উপলব্ধ ব্যালেন্স',
            value: ValueListenableBuilder<bool>(
              valueListenable: _isBalanceVisible,
              builder: (context, isVisible, child) {
                return GestureDetector(
                  onTap: () {
                    _isBalanceVisible.value = true;
                    Future.delayed(Duration(seconds: 2), () {
                      if (_isBalanceVisible.value) {
                        _isBalanceVisible.value = false;
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        AnimatedOpacity(
                          opacity: isVisible ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 400),
                          child: Text(
                            '৳${homeProvider.balance}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        AnimatedSlide(
                          offset: isVisible ? Offset(2.0, 0.0) : Offset.zero,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: AnimatedOpacity(
                            opacity: isVisible ? 0.0 : 1.0,
                            duration: Duration(milliseconds: 300),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Color(0xFF2C3E50).withOpacity(0.7),
                                  size: 15,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ব্যালেন্স দেখতে ট্যাপ করুন',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            icon: Icons.account_balance_wallet,
            isGradient: true,
            hasGlow: true,
            subtitle: 'লেনদেন দেখতে ট্যাপ করুন',
            trailing: Row(
              children: [
                Text(
                  'উত্তোলন',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WithdrawScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WithdrawScreen(),
                ),
              );
            },
          );
  }

  Widget _buildShimmerBalanceCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildLoanProgress(HomeProvider homeProvider) {
    return homeProvider.isLoading
        ? _buildShimmerLoanProgress()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ঋণের অবস্থা',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLoanStatusColor(homeProvider).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      homeProvider.getLoanStatusText(),
                      style: TextStyle(
                        color: _getLoanStatusColor(homeProvider),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: homeProvider.getLoanProgress(),
                  minHeight: 10,
                  backgroundColor: AppTheme.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getLoanStatusColor(homeProvider)),
                ),
              ),
            ],
          );
  }

  Widget _buildShimmerLoanProgress() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 20,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 20,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLoanStatusColor(HomeProvider homeProvider) {
    switch (homeProvider.loanStatus.toString()) {
      case '0':
        return AppTheme.neutral600;
      case '1':
        return AppTheme.warning;
      case '2':
        return AppTheme.success;
      case '3':
        return AppTheme.authorityBlue;
      default:
        return AppTheme.error;
    }
  }

  Widget _buildQuickActionGrid(HomeProvider homeProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine optimal number of columns based on available width
        final crossAxisCount = constraints.maxWidth < 300 ? 1 : 2;

        // Calculate optimal aspect ratio based on screen size
        final childAspectRatio = isSmallScreen
            ? 3.0
            : isMediumScreen
                ? 2.0
                : constraints.maxWidth > 600
                    ? 2.5
                    : 2.2;

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildQuickActionItem(
                'ঋণের আবেদন',
                'অর্থায়ন পান',
                Icons.monetization_on,
                () {
                  if (homeProvider.userStatus == 1 &&
                      homeProvider.loanStatus == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoanApplicationScreen(),
                      ),
                    );
                  } else if (homeProvider.userStatus == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'আপনার ইতিমধ্যে একটি পেন্ডিং বা সক্রিয় ঋণ আছে'),
                        backgroundColor: AppTheme.textDark,
                      ),
                    );
                  }
                },
                -0.2,
                100,
              ),
              _buildQuickActionItem(
                'উত্তোলন',
                'অর্থ স্থানান্তর',
                Icons.account_balance,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WithdrawScreen(),
                    ),
                  );
                },
                0.2,
                200,
              ),
              _buildQuickActionItem(
                'আমার তথ্য',
                'প্রোফাইল আপডেট করুন',
                Icons.person_outline,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalInfoScreen(),
                    ),
                  );
                },
                -0.2,
                300,
              ),
              _buildQuickActionItem(
                'সহায়তা',
                'সাহায্য নিন',
                Icons.headset_mic_outlined,
                () {
                  // Navigate to support screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactScreen(),
                    ),
                  );
                },
                0.2,
                400,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(String title, String value, IconData icon,
      VoidCallback onTap, double slideOffset, int delayMs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.authorityBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.authorityBlue,
                  size: 18,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanApplicationSection(HomeProvider homeProvider) {
    String title;
    String message;
    String? buttonText;
    VoidCallback? onPressed;

    switch (homeProvider.loanStatus.toString()) {
      case '0':
        if (homeProvider.userStatus == 0) {
          title = 'আপনার প্রোফাইল সম্পূর্ণ করুন';
          message = 'ঋণের জন্য আবেদন করতে আপনার ব্যক্তিগত তথ্য জমা দিন';
          buttonText = 'ব্যক্তিগত তথ্য';
          onPressed = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalInfoScreen(),
              ),
            );
          };
        } else {
          title = 'অর্থায়নের জন্য প্রস্তুত';
          message =
              'আপনার ব্যক্তিগত তথ্য যাচাই করা হয়েছে। এখন ঋণের জন্য আবেদন করুন।';
          buttonText = 'ঋণের জন্য আবেদন করুন';
          onPressed = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoanApplicationScreen(),
              ),
            );
          };
        }
        break;
      case '1':
        title = 'আবেদন পর্যালোচনা চলছে';
        message =
            'আপনার ঋণের আবেদন প্রক্রিয়াধীন আছে। অনুমোদিত হলে আমরা আপনাকে অবহিত করব।';
        buttonText = null;
        onPressed = null;
        break;
      case '2':
        title = 'ঋণ অনুমোদিত';
        message =
            'অভিনন্দন! আপনার ঋণ অনুমোদিত হয়েছে। আপনি এখন অর্থ উত্তোলন করতে পারেন।';
        buttonText = 'অর্থ উত্তোলন করুন';
        onPressed = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WithdrawScreen(),
            ),
          );
        };
        break;
      case '3':
        title = 'সক্রিয় ঋণ';
        message =
            'আপনার বর্তমানে একটি সক্রিয় ঋণ আছে। একটি ভালো ক্রেডিট স্কোর বজায় রাখতে সময়মত পরিশোধ করুন।';
        buttonText = null;
        onPressed = null;
        break;
      default:
        title = 'অজানা অবস্থা';
        message = 'আপনার ঋণের অবস্থা নির্ধারণে একটি ত্রুটি হয়েছে।';
        buttonText = null;
        onPressed = null;
    }

    if (homeProvider.isLoading) {
      return _buildShimmerLoanSection();
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          if (buttonText != null && onPressed != null)
            CustomButton(
              text: buttonText,
              onPressed: onPressed,
              width: double.infinity,
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoanSection() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(HomeProvider homeProvider) {
    final baseUrl = "https://wblloanschema.com/";
    final hasProfilePic = homeProvider.profilePicUrl != null &&
        homeProvider.profilePicUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: hasProfilePic
            ? Image.network(
                "$baseUrl${homeProvider.profilePicUrl!}",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Show placeholder on error
                  return Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        strokeWidth: 2.0,
                      ),
                    ),
                  );
                },
              )
            : Container(
                width: 40,
                height: 40,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade400,
                ),
              ),
      ),
    );
  }
}
