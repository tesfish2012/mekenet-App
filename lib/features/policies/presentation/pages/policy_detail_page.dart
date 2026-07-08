import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/policies_provider.dart';

class PolicyDetailPage extends ConsumerWidget {
  final int policyId;
  const PolicyDetailPage({super.key, required this.policyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insuranceAsync = ref.watch(insuranceByIdProvider(policyId));

    return Scaffold(
      appBar: AppBar(
        title: Text('policies.policy_details'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card_rounded),
            onPressed: () => context.push('/policies/$policyId/card'),
            tooltip: 'Digital Card',
          ),
        ],
      ),
      body: insuranceAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (insurance) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              AppCard(
                gradient: AppColors.primaryGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            insurance.policyTitle,
                            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      insurance.insuranceNumber,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusChip.policyStatus(insurance.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Policy Information', style: AppTextStyles.titleMedium),
                    const Divider(height: 20),
                    _DetailRow(label: 'policies.premium'.tr(),
                        value: AppFormatter.formatCurrency(insurance.premiumAmount)),
                    _DetailRow(label: 'policies.sum_assured'.tr(),
                        value: AppFormatter.formatCurrency(insurance.sumAssured)),
                    _DetailRow(label: 'policies.start_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(insurance.startDate))),
                    _DetailRow(label: 'policies.end_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(insurance.endDate))),
                    if (insurance.policyTerm != null)
                      _DetailRow(label: 'policies.policy_term'.tr(),
                          value: '${insurance.policyTerm} months'),
                    if (insurance.notes != null && insurance.notes!.isNotEmpty)
                      _DetailRow(label: 'common.notes'.tr(), value: insurance.notes!),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'policies.digital_card'.tr(),
                      onPressed: () => context.push('/policies/$policyId/card'),
                      variant: AppButtonVariant.outlined,
                      leadingIcon: Icons.credit_card_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'New Claim',
                      onPressed: () => context.push('/claims/new?insuranceId=$policyId'),
                      leadingIcon: Icons.add_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'claims.upload_documents'.tr(),
                onPressed: () => context.push('/documents'),
                variant: AppButtonVariant.outlined,
                leadingIcon: Icons.upload_file_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.titleSmall),
          ),
        ],
      ),
    );
  }
}
