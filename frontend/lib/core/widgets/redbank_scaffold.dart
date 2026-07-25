import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RedBankScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const RedBankScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: Colors.transparent, // Background provided by Container
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark 
                ? AppColors.backgroundGradientDark 
                : AppColors.backgroundGradientLight,
          ),
          child: SafeArea(
            bottom: false, // Let glass nav bar blur the background
            child: body,
          ),
        ),
      ),
    );
  }
}
