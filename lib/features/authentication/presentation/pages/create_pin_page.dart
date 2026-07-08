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

class CreatePinPage extends ConsumerStatefulWidget {
  const CreatePinPage({super.key});

  @override
  ConsumerState<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends ConsumerState<CreatePinPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;

  Future<void> _savePin() async {
    if (_pin != _confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match')),
      );
      setState(() {
        _confirming = false;
        _pin = '';
        _confirmPin = '';
      });
      return;
    }
    await getIt<SecureStorageService>().savePin(_pin);
    if (mounted) context.go(AppConstants.routeDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('auth.create_pin'.tr())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.lock_rounded, size: 56, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                _confirming ? 'auth.confirm_pin'.tr() : 'auth.create_pin'.tr(),
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _confirming
                    ? 'Enter your PIN again to confirm'
                    : 'Create a 4-digit PIN for quick access',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Pinput(
                length: 4,
                obscureText: true,
                defaultPinTheme: pinTheme,
                focusedPinTheme: pinTheme.copyDecorationWith(
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                onChanged: (v) {
                  if (!_confirming) {
                    setState(() => _pin = v);
                  } else {
                    setState(() => _confirmPin = v);
                  }
                },
                onCompleted: (v) {
                  if (!_confirming) {
                    setState(() => _confirming = true);
                  } else {
                    _savePin();
                  }
                },
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _confirming ? 'Confirm PIN' : 'Continue',
                onPressed: _pin.length == 4
                    ? () => setState(() => _confirming = true)
                    : null,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Skip for now',
                onPressed: () => context.go(AppConstants.routeDashboard),
                variant: AppButtonVariant.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
