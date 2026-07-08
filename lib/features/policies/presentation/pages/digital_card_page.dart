import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/policies_provider.dart';

class DigitalCardPage extends ConsumerWidget {
  final int insuranceId;

  const DigitalCardPage({super.key, required this.insuranceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insuranceAsync = ref.watch(insuranceByIdProvider(insuranceId));

    return Scaffold(
      appBar: AppBar(
        title: Text('policies.digital_card'.tr()),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.darkGradient,
          ),
        ),
        child: SafeArea(
          child: insuranceAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => Center(
              child: Text(e.toString(), style: const TextStyle(color: Colors.white)),
            ),
            data: (insurance) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  // Insurance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.cardGradient,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.shield_rounded, color: Colors.white, size: 36),
                            Text(
                              'SafeInsurance',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          insurance.insuranceNumber,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _CardField(
                              label: 'Policy Holder',
                              value: insurance.customerName ?? 'N/A',
                            ),
                            const SizedBox(width: 32),
                            _CardField(
                              label: 'Policy Type',
                              value: insurance.policyTypeName ?? insurance.policyTitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _CardField(
                              label: 'Valid Until',
                              value: AppFormatter.formatDate(
                                AppFormatter.parseDate(insurance.endDate),
                              ),
                            ),
                            const SizedBox(width: 32),
                            _CardField(
                              label: 'Sum Assured',
                              value: AppFormatter.formatCurrency(insurance.sumAssured),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Actions
                  AppButton(
                    label: 'policies.download_pdf'.tr(),
                    onPressed: () {/* TODO: PDF download */},
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    leadingIcon: Icons.download_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Share Card',
                    onPressed: () {/* TODO: share */},
                    variant: AppButtonVariant.outlined,
                    leadingIcon: Icons.share_rounded,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final String label;
  final String value;

  const _CardField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.overline.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
