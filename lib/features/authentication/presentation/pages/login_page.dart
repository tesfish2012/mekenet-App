import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/language_toggle_button.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    debugPrint('👉 [LOGIN] Sign In action triggered');
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ [LOGIN] Validation failed on client side');
      context.showErrorSnackBar('Please enter your email and password correctly.');
      return;
    }
    FocusScope.of(context).unfocus();
    debugPrint('🌐 [LOGIN] Calling backend API with ${_emailCtrl.text.trim()} ...');

    final success = await ref.read(authNotifierProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    debugPrint('📩 [LOGIN] API result: success=$success, mounted=$mounted');
    if (!mounted) return;

    if (success) {
      final authState = ref.read(authNotifierProvider);
      final successMsg =
          (authState.successMessage != null && authState.successMessage!.isNotEmpty)
              ? authState.successMessage!
              : 'auth.login_success'.tr();
      debugPrint('✅ [LOGIN] Showing success snackbar: $successMsg');
      context.showSuccessSnackBar(successMsg);

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          context.go(AppConstants.routeDashboard);
        }
      });
    } else {
      final authState = ref.read(authNotifierProvider);
      final errorMsg =
          (authState.errorMessage != null && authState.errorMessage!.isNotEmpty)
              ? authState.errorMessage!
              : 'Authentication failed. Please check your credentials.';
      debugPrint('❌ [LOGIN] Showing error snackbar: $errorMsg');
      context.showErrorSnackBar(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authNotifierProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    onSurface: Colors.white,
                    primary: Colors.white,
                  ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withOpacity(0.12),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                ),
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.45),
                ),
                errorStyle: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFFFCA5A5),
                ),
                prefixIconColor: Colors.white70,
                suffixIconColor: Colors.white70,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppConstants.logoAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn()
                            .scale(begin: const Offset(0.8, 0.8)),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.appName,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 6),
                        Text(
                          'auth.sign_in'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Fields
                  AppTextField(
                    label: 'auth.email'.tr(),
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.email,
                    hint: 'you@example.com',
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  PasswordField(
                    label: 'auth.password'.tr(),
                    controller: _passwordCtrl,
                    validator: Validators.loginPassword,
                    onFieldSubmitted: (_) => _login(),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 14),

                  // Remember me + Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                              activeColor: Colors.white,
                              checkColor: AppColors.primary,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'auth.remember_me'.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(AppConstants.routeForgotPassword),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'auth.forgot_password'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 24),

                  // Login button (White button with primary text on primary background)
                  AppButton(
                    label: 'auth.sign_in'.tr(),
                    onPressed: _login,
                    isLoading: isLoading,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 14),

                  // Biometric option
                  Consumer(
                    builder: (context, ref, _) {
                      final biometricEnabled =
                          ref.watch(biometricEnabledProvider);
                      return biometricEnabled.maybeWhen(
                        data: (enabled) => enabled
                            ? AppButton(
                                label: 'auth.biometric_login'.tr(),
                                onPressed: () {/* TODO: biometric auth */},
                                variant: AppButtonVariant.outlined,
                                leadingIcon: Icons.fingerprint_rounded,
                                foregroundColor: Colors.white,
                              ).animate().fadeIn(delay: 700.ms)
                            : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.white24),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white60,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.white24),
                      ),
                    ],
                  ).animate().fadeIn(delay: 750.ms),
                  const SizedBox(height: 24),

                  // Side-by-side: "Don't have an account?" + Small compact Sign Up button
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () =>
                              context.push(AppConstants.routeRegister),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'auth.sign_up'.tr(),
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),

          // ── Language toggle — floats top-right ──────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: const LanguageToggleButton(onDark: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
