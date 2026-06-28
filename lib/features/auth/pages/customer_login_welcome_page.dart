import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/mock/mock_data.dart';
import 'package:my_first_app/shared/widgets/doll_girl_character.dart';
import 'package:my_first_app/features/dashboard/pages/customer_dashboard_page.dart';

class CustomerLoginWelcomePage extends StatefulWidget {
  const CustomerLoginWelcomePage({super.key});

  @override
  State<CustomerLoginWelcomePage> createState() =>
      _CustomerLoginWelcomePageState();
}

class _CustomerLoginWelcomePageState extends State<CustomerLoginWelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textController;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    Future<void>.delayed(const Duration(milliseconds: 2800), _goToDashboard);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CustomerDashboardPage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = AppController.instance.userName ?? 'Customer';
    final textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              const DollGirlCharacter(),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: textOpacity,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(textOpacity),
                  child: Column(
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        MockData.tagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              FadeTransition(
                opacity: textOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToDashboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Go to Dashboard',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
