import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
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
      backgroundColor: AppColors.lightBackground,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myInsurancesProvider),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Branded hero header ──────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.secondary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF060D1A), Color(0xFF0B1629)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'policies.my_policies'.tr(),
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/policies/browse'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add_rounded,
                                          color: Colors.white, size: 15),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Browse',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          insurancesAsync.whenData((list) {
                            final active = list
                                .where((i) =>
                                    i.status.toUpperCase() == 'ACTIVE')
                                .length;
                            return Row(
                              children: [
                                _HeroStat(
                                  label: 'Total',
                                  value: '${list.length}',
                                  icon: Icons.shield_rounded,
                                ),
                                const SizedBox(width: 20),
                                _HeroStat(
                                  label: 'Active',
                                  value: '$active',
                                  icon: Icons.check_circle_outline_rounded,
                                  valueColor: AppColors.success,
                                ),
                              ],
                            );
                          }).value ??
                              const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── List content ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: insurancesAsync.when(
                loading: () => const SliverToBoxAdapter(
                    child: ShimmerList(itemHeight: 130)),
                error: (e, _) => SliverToBoxAdapter(
                  child: ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(myInsurancesProvider),
                  ),
                ),
                data: (insurances) => insurances.isEmpty
                    ? SliverToBoxAdapter(
                        child: EmptyView(
                          title: 'policies.no_policies'.tr(),
                          subtitle:
                              'Browse available policies to get started.',
                          icon: Icons.shield_outlined,
                          actionLabel: 'policies.browse_policies'.tr(),
                          onAction: () => context.push('/policies/browse'),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _InsuranceCard(
                              insurance: insurances[index],
                              index: index,
                            ),
                          ),
                          childCount: insurances.length,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero stat widget ───────────────────────────────────────

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: valueColor ?? Colors.white60, size: 14),
        const SizedBox(width: 5),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}

// ── Insurance card ─────────────────────────────────────────

class _InsuranceCard extends StatelessWidget {
  final InsuranceModel insurance;
  final int index;

  const _InsuranceCard({required this.insurance, required this.index});

  // Icon by policy type keyword
  IconData _policyIcon() {
    final t = insurance.policyTitle.toLowerCase() +
        (insurance.policyTypeName ?? '').toLowerCase();
    if (t.contains('life')) return Icons.favorite_rounded;
    if (t.contains('health') || t.contains('medical'))
      return Icons.local_hospital_rounded;
    if (t.contains('car') || t.contains('vehicle') || t.contains('motor'))
      return Icons.directions_car_rounded;
    if (t.contains('home') || t.contains('property'))
      return Icons.home_rounded;
    if (t.contains('travel')) return Icons.flight_rounded;
    return Icons.shield_rounded;
  }

  bool get _isActive => insurance.status.toUpperCase() == 'ACTIVE';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/policies/${insurance.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lightBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Card top: gradient banner ──────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  // Type icon bubble
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_policyIcon(),
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insurance.policyTitle,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          insurance.insuranceNumber,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white60,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status chip on dark bg
                  _DarkStatusChip(status: insurance.status),
                ],
              ),
            ),

            // ── Card bottom: info row ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  _InfoCell(
                    label: 'policies.premium'.tr(),
                    value: AppFormatter.formatCurrency(insurance.premiumAmount),
                    valueColor: AppColors.primary,
                  ),
                  _Divider(),
                  _InfoCell(
                    label: 'policies.sum_assured'.tr(),
                    value: AppFormatter.formatCurrency(insurance.sumAssured),
                  ),
                  _Divider(),
                  _InfoCell(
                    label: 'policies.expiry_date'.tr(),
                    value: insurance.endDate != null
                        ? AppFormatter.formatDate(
                            AppFormatter.parseDate(insurance.endDate))
                        : '—',
                    valueColor: _isActive ? null : AppColors.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 300.ms)
        .slideY(begin: 0.08, duration: 300.ms);
  }
}

class _DarkStatusChip extends StatelessWidget {
  final String status;
  const _DarkStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = AppColors.success;
        break;
      case 'PENDING':
        color = AppColors.accent;
        break;
      case 'EXPIRED':
        color = AppColors.error;
        break;
      default:
        color = AppColors.grey400;
    }
    final label = status[0].toUpperCase() +
        status.substring(1).toLowerCase().replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCell(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.grey400, fontSize: 10)),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: valueColor ?? AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.lightBorder,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
