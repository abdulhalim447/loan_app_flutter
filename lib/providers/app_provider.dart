import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_provider.dart';
import 'home_provider.dart';
import 'withdraw_provider.dart';
import 'personal_info_provider.dart';

/// This class provides all the providers needed in the app in one place
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawProvider()),
        ChangeNotifierProvider(create: (_) => PersonalInfoProvider()),
        // Add more providers here as needed
      ],
      child: child,
    );
  }
}
