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
import '../providers/policies_provider.dart';
import '../../data/models/policy_model.dart';

class PoliciesPage extends ConsumerWidget {
  const PoliciesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insurancesAsync = ref.watch(myInsurancesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('policies.my_policies'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/policies/browse'),
            tooltip: 'Browse Policies',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myInsurancesProvider),
        color: AppColors.primary,
        child: insurancesAsync.when(
          loading: () => const ShimmerList(itemHeight: 100),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(myInsurancesProvider),
          ),
          data: (insurances) => insurances.isEmpty
              ? EmptyView(
                  title: 'policies.no_policies'.tr(),
                  subtitle: 'Browse available policies to get started.',
                  icon: Icons.shield_outlined,
                  actionLabel: 'policies.browse_policies'.tr(),
                  onAction: () => context.push('/policies/browse'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: insurances.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _InsuranceCard(
                    insurance: insurances[index],
                    index: index,
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/policies/browse'),
        icon: const Icon(Icons.add_rounded),
        label: Text('policies.browse_policies'.tr()),
      ),
    );
  }
}

class _InsuranceCard extends StatelessWidget {
  final InsuranceModel insurance;
  final int index;

  const _InsuranceCard({required this.insurance, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/policies/${insurance.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insurance.policyTitle,
                      style: AppTextStyles.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      insurance.insuranceNumber,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusChip.policyStatus(insurance.status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoItem(
                label: 'policies.premium'.tr(),
                value: AppFormatter.formatCurrency(insurance.premiumAmount),
              ),
              _InfoItem(
                label: 'policies.sum_assured'.tr(),
                value: AppFormatter.formatCurrency(insurance.sumAssured),
              ),
              _InfoItem(
                label: 'policies.expiry_date'.tr(),
                value: insurance.endDate != null
                    ? AppFormatter.formatDate(AppFormatter.parseDate(insurance.endDate))
                    : '—',
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
