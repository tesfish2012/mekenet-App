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
import '../providers/policies_provider.dart';
import '../../data/models/policy_model.dart';

class BrowsePoliciesPage extends ConsumerStatefulWidget {
  const BrowsePoliciesPage({super.key});

  @override
  ConsumerState<BrowsePoliciesPage> createState() => _BrowsePoliciesPageState();
}

class _BrowsePoliciesPageState extends ConsumerState<BrowsePoliciesPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(policySearchQueryProvider);
    final policiesAsync = query.isEmpty
        ? ref.watch(browsePoliciesProvider)
        : ref.watch(searchPoliciesProvider(query));

    return Scaffold(
      appBar: AppBar(title: Text('policies.browse_policies'.tr())),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  ref.read(policySearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'common.search'.tr(),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(policySearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(browsePoliciesProvider),
              color: AppColors.primary,
              child: policiesAsync.when(
                loading: () => const ShimmerList(itemHeight: 120),
                error: (e, _) => ErrorView(message: e.toString()),
                data: (policies) => policies.isEmpty
                    ? EmptyView(
                        title: 'No policies found',
                        subtitle: 'Try a different search term.',
                        icon: Icons.search_off_rounded,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: policies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _PolicyCard(
                          policy: policies[index],
                          index: index,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final PolicyModel policy;
  final int index;

  const _PolicyCard({required this.policy, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/policies/browse/${policy.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(policy.title, style: AppTextStyles.titleSmall),
                    if (policy.policyTypeName.isNotEmpty)
                      Text(policy.policyTypeName, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatter.formatCurrency(policy.minPremium),
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                  ),
                  Text('min premium', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          if (policy.description != null && policy.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              policy.description!,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (policy.coverageType != null)
                _Tag(label: policy.coverageType!),
              if (policy.liabilityRisk != null) ...[
                const SizedBox(width: 6),
                _Tag(label: 'Risk: ${policy.liabilityRisk!}'),
              ],
              if (policy.durationMonths > 0) ...[
                const SizedBox(width: 6),
                _Tag(label: '${policy.durationMonths}mo'),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1);
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
    );
  }
}
