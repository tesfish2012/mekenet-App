import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/claims_provider.dart';

class ClaimDetailPage extends ConsumerWidget {
  final int claimId;
  const ClaimDetailPage({super.key, required this.claimId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimAsync = ref.watch(claimByIdProvider(claimId));

    return Scaffold(
      appBar: AppBar(title: Text('claims.claim_details'.tr())),
      body: claimAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (claim) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppCard(
                gradient: AppColors.cardGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            claim.claimNumber,
                            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatusChip.claimStatus(claim.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Claim Info
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Claim Information', style: AppTextStyles.titleMedium),
                    const Divider(height: 20),
                    _Row(label: 'claims.claim_amount'.tr(),
                        value: AppFormatter.formatCurrency(claim.claimAmount)),
                    if (claim.approvedAmount != null)
                      _Row(label: 'claims.approved_amount'.tr(),
                          value: AppFormatter.formatCurrency(claim.approvedAmount!)),
                    _Row(label: 'claims.incident_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(claim.incidentDate))),
                    _Row(label: 'claims.claim_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(claim.claimDate))),
                    if (claim.policyTitle != null)
                      _Row(label: 'Policy', value: claim.policyTitle!),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description
              if (claim.description != null) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('claims.description'.tr(), style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(claim.description!, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Admin Notes
              if (claim.adminNotes != null && claim.adminNotes!.isNotEmpty) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Notes', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(claim.adminNotes!, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Upload documents
              AppButton(
                label: 'claims.upload_documents'.tr(),
                onPressed: () {},
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Expanded(child: Text(value, style: AppTextStyles.titleSmall)),
        ],
      ),
    );
  }
}
