import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class PinLoginPage extends ConsumerStatefulWidget {
  const PinLoginPage({super.key});

  @override
  ConsumerState<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends ConsumerState<PinLoginPage> {
  String _pin = '';
  bool _error = false;

  Future<void> _verify() async {
    final storedPin = await getIt<SecureStorageService>().getPin();
    if (_pin == storedPin) {
      if (mounted) context.go(AppConstants.routeDashboard);
    } else {
      setState(() {
        _error = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
      decoration: BoxDecoration(
        color: _error ? AppColors.errorLight : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _error ? AppColors.error : AppColors.lightBorder,
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 56, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('auth.pin_login'.tr(), style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit PIN',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 40),
              Pinput(
                length: 4,
                obscureText: true,
                defaultPinTheme: pinTheme,
                focusedPinTheme: pinTheme.copyDecorationWith(
                  border: Border.all(
                    color: _error ? AppColors.error : AppColors.primary,
                    width: 2,
                  ),
                ),
                onChanged: (v) => setState(() {
                  _pin = v;
                  _error = false;
                }),
                onCompleted: (_) => _verify(),
              ),
              if (_error) ...[
                const SizedBox(height: 12),
                Text(
                  'Incorrect PIN. Please try again.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 40),
              AppButton(
                label: 'Use Password Instead',
                onPressed: () => context.go(AppConstants.routeLogin),
                variant: AppButtonVariant.outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
