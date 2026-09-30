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
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Full logo — no circle clip, no padding crop
            Image.asset(
              AppConstants.logoAsset,
              width: MediaQuery.of(context).size.width * 0.68,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.85, 0.85)),

            const Spacer(flex: 2),

            // Loading indicator in brand navy
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.6),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 52),
          ],
        ),
      ),
    );
  }
}
