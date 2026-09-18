import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/injectable_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/app_update_service.dart';
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
    // Check for a mandatory update from Play Store before doing anything
    await AppUpdateService.checkForUpdate(context, flexible: false);

    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDuration),
    );
    if (!mounted) return;

    final prefs = getIt<PreferencesService>();
    final authState = ref.read(authNotifierProvider);

    if (!prefs.isOnboardingDone()) {
      context.go(AppConstants.routeOnboarding);
    } else if (authState.isAuthenticated) {
      context.go(AppConstants.routeDashboard);
    } else {
      context.go(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.accentGradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Logo – large circle with white bg, no clipping
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Image.asset(
                AppConstants.logoAsset,
                fit: BoxFit.contain,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.7, 0.7)),

            const SizedBox(height: 28),

            // App name in brand navy
            Text(
              AppConstants.appName,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 8),

            // Tagline
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary.withOpacity(0.7),
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms),

            const Spacer(flex: 2),

            // Loading indicator in brand navy
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.7),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
