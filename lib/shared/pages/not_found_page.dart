import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '404',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.primary,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 16),
                Text(
                  'pages.not_found'.tr(),
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 8),
                Text(
                  'pages.not_found_subtitle'.tr(),
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 40),
                AppButton(
                  label: 'pages.go_home'.tr(),
                  onPressed: () => context.go(AppConstants.routeDashboard),
                  leadingIcon: Icons.home_rounded,
                  width: 200,
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
