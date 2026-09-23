import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/policies_provider.dart';

// ── Args passed from apply page ───────────────────────────

class PolicyPaymentArgs {
  final int policyId;
  final String policyTitle;
  final String planLabel;
  final double amount;
  final double sumAssured;
  final String startDate;
  final String endDate;
  final int policyTerm;
  final String? notes;

  const PolicyPaymentArgs({
    required this.policyId,
    required this.policyTitle,
    required this.planLabel,
    required this.amount,
    required this.sumAssured,
    required this.startDate,
    required this.endDate,
    required this.policyTerm,
    this.notes,
  });
}

// ── Payment methods definition ────────────────────────────

enum _PaymentMethod { telebirr, yayaWallet }

extension _PaymentMethodX on _PaymentMethod {
  String get label {
    switch (this) {
      case _PaymentMethod.telebirr:
        return 'Telebirr';
      case _PaymentMethod.yayaWallet:
        return 'Yaya Wallet';
    }
  }

  String get subtitle {
    switch (this) {
      case _PaymentMethod.telebirr:
        return 'Pay via Ethio Telecom mobile wallet';
      case _PaymentMethod.yayaWallet:
        return 'Pay via Yaya digital wallet';
    }
  }

  String get logoPath {
    switch (this) {
      case _PaymentMethod.telebirr:
        return 'assets/images/telebirr.png';
      case _PaymentMethod.yayaWallet:
        return 'assets/images/yaya_wallet.png';
    }
  }

  IconData get fallbackIcon {
    switch (this) {
      case _PaymentMethod.telebirr:
        return Icons.phone_android_rounded;
      case _PaymentMethod.yayaWallet:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get color {
    switch (this) {
      case _PaymentMethod.telebirr:
        return const Color(0xFF007BFF);
      case _PaymentMethod.yayaWallet:
        return const Color(0xFFE91E8C);
    }
  }
}

// ── Page ─────────────────────────────────────────────────

class PolicyPaymentPage extends ConsumerStatefulWidget {
  final PolicyPaymentArgs args;

  const PolicyPaymentPage({super.key, required this.args});

  @override
  ConsumerState<PolicyPaymentPage> createState() => _PolicyPaymentPageState();
}

class _PolicyPaymentPageState extends ConsumerState<PolicyPaymentPage> {
  _PaymentMethod? _selected;
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    // Payment method selection is UI-only (future integration).
    // Submission proceeds regardless of which method is highlighted.

    setState(() => _isProcessing = true);

    try {
      // Submit the insurance application
      final dio = getIt<Dio>();
      final response = await dio.post(
        ApiEndpoints.portalInsurances,
        data: {
          'policyId': widget.args.policyId,
          'sumAssured': widget.args.sumAssured,
          'premiumAmount': widget.args.amount,
          'startDate': widget.args.startDate,
          'endDate': widget.args.endDate,
          'policyTerm': widget.args.policyTerm,
          'status': 'PENDING',
          if (widget.args.notes != null) 'notes': widget.args.notes,
        },
      );

      ref.invalidate(myInsurancesProvider);

      if (!mounted) return;

      // Show coming-soon sheet — passes selected method (or default) for display only
      await _showComingSoonSheet();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map?)?['message'] as String? ??
          e.message ??
          'Failed to process. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showComingSoonSheet() async {
    final method = _selected ?? _PaymentMethod.telebirr;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PaymentSuccessSheet(
        method: method,
        amount: widget.args.amount,
        onDone: () {
          Navigator.of(context).pop();
          context.go('/policies');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Choose Payment Method',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order summary card ────────────────────────
            AppCard(
              gradient: AppColors.primaryGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              args.policyTitle,
                              style: AppTextStyles.titleSmall
                                  .copyWith(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              args.planLabel,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CardInfo(
                          label: 'Start Date', value: args.startDate),
                      _CardInfo(
                          label: 'End Date', value: args.endDate),
                      _CardInfo(
                        label: 'Total Amount',
                        value: AppFormatter.formatCurrency(args.amount),
                        highlight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 28),

            Text('Select Payment Method',
                style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Choose how you want to pay your premium',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 16),

            // ── Payment method cards ──────────────────────
            ..._PaymentMethod.values.asMap().entries.map((entry) {
              final i = entry.key;
              final method = entry.value;
              final isSelected = _selected == method;

              return GestureDetector(
                onTap: () => setState(() => _selected = method),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? method.color.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? method.color : AppColors.lightBorder,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? method.color : AppColors.primary)
                            .withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Logo / icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: method.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            method.logoPath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              method.fallbackIcon,
                              color: method.color,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.label,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isSelected
                                    ? method.color
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              method.subtitle,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.grey500),
                            ),
                          ],
                        ),
                      ),
                      // Radio indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? method.color : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? method.color
                                : AppColors.grey300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (i * 80).ms, duration: 250.ms)
                  .slideY(begin: 0.06);
            }),

            const SizedBox(height: 8),

            // ── Notice (payment gateway coming soon) ─────
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: AppColors.accentContainer,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(
            //         color: AppColors.accent.withOpacity(0.3), width: 1),
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.info_outline_rounded,
            //           color: AppColors.accentDark, size: 18),
            //       const SizedBox(width: 10),
            //       Expanded(
            //         child: Text(
            //           'Payment gateway integration is in progress. '
            //           'Your application will be submitted and our team will contact you.',
            //           style: AppTextStyles.bodySmall.copyWith(
            //             color: AppColors.accentDark,
            //             height: 1.5,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 28),

            // ── Confirm button ────────────────────────────
            AppButton(
              label: _selected != null
                  ? 'Pay ${AppFormatter.formatCurrency(args.amount)} via ${_selected!.label}'
                  : 'Pay ${AppFormatter.formatCurrency(args.amount)}',
              onPressed: _isProcessing || _selected == null
                  ? null
                  : _confirmPayment,
              isLoading: _isProcessing,
              leadingIcon: Icons.lock_rounded,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Back',
              onPressed: () => context.pop(),
              variant: AppButtonVariant.outlined,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Coming soon bottom sheet ──────────────────────────────

// ── Payment Success Sheet ─────────────────────────────────

class _PaymentSuccessSheet extends StatelessWidget {
  final _PaymentMethod method;
  final double amount;
  final VoidCallback onDone;

  const _PaymentSuccessSheet({
    required this.method,
    required this.amount,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Success icon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 52,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Payment Successful!',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Amount paid
          Text(
            AppFormatter.formatCurrency(amount),
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            'Paid via ${method.label}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Policy Activated Successfully',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Go to policies button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Go to My Policies',
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────

class _CardInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _CardInfo({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.overline.copyWith(
            color: Colors.white60,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: highlight
              ? AppTextStyles.titleMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                )
              : AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
