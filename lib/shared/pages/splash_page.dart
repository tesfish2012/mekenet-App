import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/injectable_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/preferences_service.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDuration),
    );
    if (!mounted) return;

    final prefs = getIt<PreferencesService>();
    final authState = ref.read(authNotifierProvider);

    if (!prefs.isOnboardingDone()) {
      context.go(AppConstants.routeOnboarding);
    } else if (authState.isAuthenticated) {
      // Check if PIN login is preferred
      final secureStorage = ref.read(authRepositoryProvider);
      context.go(AppConstants.routeDashboard);
    } else {
      context.go(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.darkGradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Brand mark
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 64,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.5, 0.5)),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'Your Insurance Partner',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms),
            const SizedBox(height: 80),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.6),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
