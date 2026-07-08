import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/claims_provider.dart';
import '../../data/models/claim_model.dart';

class ClaimsPage extends ConsumerWidget {
  const ClaimsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(myClaimsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('claims.my_claims'.tr())),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myClaimsProvider),
        color: AppColors.primary,
        child: claimsAsync.when(
          loading: () => const ShimmerList(itemHeight: 100),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(myClaimsProvider),
          ),
          data: (claims) => claims.isEmpty
              ? EmptyView(
                  title: 'claims.no_claims'.tr(),
                  subtitle: 'Submit a claim for an active policy.',
                  icon: Icons.assignment_outlined,
                  actionLabel: 'claims.new_claim'.tr(),
                  onAction: () => context.push('/claims/new'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: claims.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ClaimCard(
                    claim: claims[index],
                    index: index,
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/claims/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text('claims.new_claim'.tr()),
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  final ClaimModel claim;
  final int index;

  const _ClaimCard({required this.claim, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/claims/${claim.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_rounded, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claim.claimNumber, style: AppTextStyles.titleSmall),
                    if (claim.policyTitle != null)
                      Text(claim.policyTitle!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              StatusChip.claimStatus(claim.status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoItem(
                label: 'claims.claim_amount'.tr(),
                value: AppFormatter.formatCurrency(claim.claimAmount),
              ),
              _InfoItem(
                label: 'claims.incident_date'.tr(),
                value: AppFormatter.formatDate(AppFormatter.parseDate(claim.incidentDate)),
              ),
              if (claim.approvedAmount != null)
                _InfoItem(
                  label: 'claims.approved_amount'.tr(),
                  value: AppFormatter.formatCurrency(claim.approvedAmount!),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1);
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.titleSmall, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
