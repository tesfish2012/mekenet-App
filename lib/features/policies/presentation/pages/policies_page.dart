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

import '../providers/renewals_provider.dart';
import '../../data/models/renewal_model.dart';

class PoliciesPage extends ConsumerStatefulWidget {
  const PoliciesPage({super.key});

  @override
  ConsumerState<PoliciesPage> createState() => _PoliciesPageState();
}

class _PoliciesPageState extends ConsumerState<PoliciesPage> {
  int _selectedTab = 0; // 0 = Policies, 1 = Renewals

  @override
  Widget build(BuildContext context) {
    final insurancesAsync = ref.watch(myInsurancesProvider);
    final renewalsAsync = ref.watch(myRenewalsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedTab == 0) {
            ref.invalidate(myInsurancesProvider);
          } else {
            ref.invalidate(myRenewalsProvider);
          }
        },
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
                                _selectedTab == 0
                                    ? 'policies.my_policies'.tr()
                                    : 'Policy Renewals',
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
                          if (_selectedTab == 0)
                            insurancesAsync.whenData((list) {
                              final active = list
                                  .where((i) =>
                                      i.status.toUpperCase() == 'ACTIVE')
                                  .length;
                              final pending = list
                                  .where((i) =>
                                      i.status.toUpperCase() == 'PENDING' ||
                                      i.status.toUpperCase() == 'IN_REVIEW' ||
                                      i.status.toUpperCase() == 'NEW')
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
                                  if (pending > 0) ...[
                                    const SizedBox(width: 20),
                                    _HeroStat(
                                      label: 'Pending',
                                      value: '$pending',
                                      icon: Icons.hourglass_top_rounded,
                                      valueColor: AppColors.accent,
                                    ),
                                  ],
                                ],
                              );
                            }).value ??
                                const SizedBox.shrink()
                          else
                            renewalsAsync.whenData((list) {
                              final pending = list
                                  .where((r) =>
                                      r.status.toUpperCase() == 'PENDING' ||
                                      r.status.toUpperCase() == 'SUBMITTED')
                                  .length;
                              return Row(
                                children: [
                                  _HeroStat(
                                    label: 'Total Renewals',
                                    value: '${list.length}',
                                    icon: Icons.autorenew_rounded,
                                  ),
                                  const SizedBox(width: 20),
                                  _HeroStat(
                                    label: 'Pending',
                                    value: '$pending',
                                    icon: Icons.hourglass_top_rounded,
                                    valueColor: AppColors.accent,
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

            // ── Tab switcher ─────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentTab(
                        label: 'policies.my_policies'.tr(),
                        icon: Icons.shield_rounded,
                        count: insurancesAsync.value?.length,
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentTab(
                        label: 'Renewals',
                        icon: Icons.autorenew_rounded,
                        count: renewalsAsync.value?.length,
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── List content ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              sliver: _selectedTab == 0
                  ? insurancesAsync.when(
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
                                onAction: () =>
                                    context.push('/policies/browse'),
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
                    )
                  : renewalsAsync.when(
                      loading: () => const SliverToBoxAdapter(
                          child: ShimmerList(itemHeight: 130)),
                      error: (e, _) => SliverToBoxAdapter(
                        child: ErrorView(
                          message: e.toString(),
                          onRetry: () => ref.invalidate(myRenewalsProvider),
                        ),
                      ),
                      data: (renewals) => renewals.isEmpty
                          ? SliverToBoxAdapter(
                              child: EmptyView(
                                title: 'No renewal requests',
                                subtitle:
                                    'You can request a renewal from any policy details page.',
                                icon: Icons.autorenew_rounded,
                                actionLabel: 'View Policies',
                                onAction: () =>
                                    setState(() => _selectedTab = 0),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _RenewalCard(
                                    renewal: renewals[index],
                                    index: index,
                                  ),
                                ),
                                childCount: renewals.length,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/policies/${insurance.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
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
      case 'IN_REVIEW':
      case 'CONFIRM':
        color = AppColors.warning;
        break;
      case 'NEW':
        color = AppColors.primaryLight;
        break;
      case 'EXPIRED':
        color = AppColors.error;
        break;
      case 'CANCELLED':
        color = AppColors.grey400;
        break;
      default:
        color = AppColors.grey400;
    }
    final label = status
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
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
                .copyWith(color: AppTextStyles.textSecondaryColor, fontSize: 10)),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
                color: valueColor == AppColors.primary &&
                    Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextPrimary
                  : valueColor ?? AppTextStyles.textPrimaryColor,
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

// ── Segment Tab ────────────────────────────────────────────

class _SegmentTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.icon,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : AppTextStyles.textSecondaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTextStyles.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : isDark
                        ? AppColors.darkCard
                        : AppColors.grey200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppTextStyles.textSecondaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Renewal Card ───────────────────────────────────────────

class _RenewalCard extends StatelessWidget {
  final RenewalModel renewal;
  final int index;

  const _RenewalCard({required this.renewal, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Gradient banner ──────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.autorenew_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        renewal.renewalRef ?? 'Renewal #${renewal.id}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Policy #${renewal.insuranceNumber}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                _DarkStatusChip(status: renewal.status),
              ],
            ),
          ),

          // ── Body: Financial metrics & timeline ───────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _InfoCell(
                      label: 'NEW PREMIUM',
                      value: AppFormatter.formatCurrency(renewal.newPremiumAmount),
                      valueColor: AppColors.primary,
                    ),
                    _Divider(),
                    _InfoCell(
                      label: 'NEW SUM ASSURED',
                      value: AppFormatter.formatCurrency(renewal.newSumAssured),
                    ),
                    _Divider(),
                    _InfoCell(
                      label: 'TERM',
                      value: renewal.newPolicyTerm != null
                          ? '${renewal.newPolicyTerm} mos'
                          : '12 mos',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 13, color: AppColors.grey400),
                    const SizedBox(width: 5),
                    Text(
                      'Dates: ${renewal.newStartDate ?? renewal.renewalDate ?? 'N/A'} → ${renewal.newEndDate ?? 'N/A'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTextStyles.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (renewal.rejectionReason != null &&
                    renewal.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reason: ${renewal.rejectionReason}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (renewal.adminNotes != null &&
                    renewal.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Note: ${renewal.adminNotes}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTextStyles.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 250.ms)
        .slideY(begin: 0.06, duration: 250.ms);
  }
}

