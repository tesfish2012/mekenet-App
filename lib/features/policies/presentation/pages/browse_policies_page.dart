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
import '../providers/policies_provider.dart';
import '../../data/models/policy_model.dart';

class BrowsePoliciesPage extends ConsumerStatefulWidget {
  const BrowsePoliciesPage({super.key});

  @override
  ConsumerState<BrowsePoliciesPage> createState() =>
      _BrowsePoliciesPageState();
}

class _BrowsePoliciesPageState extends ConsumerState<BrowsePoliciesPage> {
  final _searchCtrl = TextEditingController();
  final _chipScrollCtrl = ScrollController();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    // Auto-scroll to the selected chip after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    final selectedId = ref.read(selectedPolicyTypeIdProvider);
    if (selectedId == null || !_chipScrollCtrl.hasClients) return;

    final types = ref.read(policyTypesProvider).value ?? [];

    // Slot 0 = "All", slot 1 = "Vehicle/Motor", then types start at slot 2
    int chipIndex;
    if (selectedId == -1) {
      chipIndex = 1; // Vehicle/Motor
    } else {
      final typeIndex = types.indexWhere((t) => t.id == selectedId);
      if (typeIndex < 0) return;
      chipIndex = typeIndex + 2;
    }

    // Each chip is roughly 118px wide + 8px gap; bring it into the center
    const chipWidth = 118.0;
    const chipGap = 8.0;
    final targetOffset = (chipIndex * (chipWidth + chipGap)) -
        (_chipScrollCtrl.position.viewportDimension / 2) +
        (chipWidth / 2);

    _chipScrollCtrl.animateTo(
      targetOffset.clamp(0.0, _chipScrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _chipScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(policySearchQueryProvider);
    final selectedTypeId = ref.watch(selectedPolicyTypeIdProvider);
    final policyTypesAsync = ref.watch(policyTypesProvider);
    final isVehicleCategory = selectedTypeId == -1;

    final AsyncValue<List<PolicyModel>> rawPoliciesAsync;
    if (isVehicleCategory) {
      rawPoliciesAsync = ref.watch(vehiclePoliciesProvider);
    } else if (query.isNotEmpty) {
      rawPoliciesAsync = ref.watch(searchPoliciesProvider(query));
    } else {
      rawPoliciesAsync = ref.watch(browsePoliciesProvider);
    }

    final policiesAsync = rawPoliciesAsync.whenData((list) {
      var filtered = list;
      if (selectedTypeId != null && selectedTypeId > 0) {
        filtered = filtered.where((p) => p.policyTypeId == selectedTypeId).toList();
      }
      if (query.isNotEmpty && isVehicleCategory) {
        final q = query.toLowerCase();
        filtered = filtered
            .where((p) =>
                p.title.toLowerCase().contains(q) ||
                p.code.toLowerCase().contains(q) ||
                (p.description?.toLowerCase().contains(q) ?? false))
            .toList();
      }
      return filtered;
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Branded header with search ─────────────────────
          SliverAppBar(
            expandedHeight: 148,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.secondary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              },
            ),
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'policies.browse_policies'.tr(),
                          style: AppTextStyles.headlineMedium
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find the right coverage for you',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white54),
                        ),
                        const SizedBox(height: 12),
                        // Search bar
                        Focus(
                          onFocusChange: (v) =>
                              setState(() => _searchFocused = v),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(_searchFocused ? 1.0 : 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _searchFocused
                                    ? AppColors.accent
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                  color: _searchFocused
                                      ? AppColors.primary
                                      : Colors.white60,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (v) => ref
                                        .read(policySearchQueryProvider
                                            .notifier)
                                        .state = v,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: _searchFocused
                                          ? AppTextStyles.textPrimaryColor
                                          : Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'common.search'.tr(),
                                      hintStyle:
                                          AppTextStyles.bodyMedium.copyWith(
                                        color: _searchFocused
                                            ? AppColors.grey400
                                            : Colors.white38,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (query.isNotEmpty) ...[
                                  GestureDetector(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      ref
                                          .read(policySearchQueryProvider
                                              .notifier)
                                          .state = '';
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.close_rounded,
                                          size: 16,
                                          color: AppColors.grey400),
                                    ),
                                  ),
                                ] else
                                  const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Category filter chips (from /portal/policies/types + vehicle) ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: policyTypesAsync.when(
                loading: () => const SizedBox(
                  height: 38,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (types) {
                  return SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      controller: _chipScrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _CategoryChip(
                          label: 'All',
                          icon: Icons.grid_view_rounded,
                          isSelected: selectedTypeId == null,
                          onTap: () {
                            ref
                                .read(selectedPolicyTypeIdProvider.notifier)
                                .state = null;
                          },
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: 'Vehicle / Motor',
                          icon: Icons.directions_car_rounded,
                          isSelected: selectedTypeId == -1,
                          onTap: () {
                            ref
                                .read(selectedPolicyTypeIdProvider.notifier)
                                .state = selectedTypeId == -1 ? null : -1;
                          },
                        ),
                        for (final type in types) ...[
                          const SizedBox(width: 8),
                          _CategoryChip(
                            label: type.name,
                            icon: _categoryIcon(type.name),
                            isSelected: selectedTypeId == type.id,
                            onTap: () {
                              ref
                                  .read(selectedPolicyTypeIdProvider.notifier)
                                  .state =
                                  selectedTypeId == type.id ? null : type.id;
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Results count bar ──────────────────────────────
          SliverToBoxAdapter(
            child: policiesAsync.whenData((list) {
              return Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${list.length} policies',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isVehicleCategory)
                      Text(
                        'Vehicle insurance',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                      )
                    else if (query.isNotEmpty)
                      Text(
                        'for "$query"',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppTextStyles.textSecondaryColor),
                      ),
                  ],
                ),
              );
            }).value ??
                const SizedBox.shrink(),
          ),

          // ── Policy list ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: policiesAsync.when(
              loading: () => const SliverToBoxAdapter(
                  child: ShimmerList(itemHeight: 150)),
              error: (e, _) => SliverToBoxAdapter(
                child: ErrorView(message: e.toString()),
              ),
              data: (policies) => policies.isEmpty
                  ? SliverToBoxAdapter(
                      child: EmptyView(
                        title: 'No policies found',
                        subtitle: 'Try a different search term.',
                        icon: Icons.search_off_rounded,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PolicyCard(
                            policy: policies[index],
                            index: index,
                          ),
                        ),
                        childCount: policies.length,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Policy catalogue card ──────────────────────────────────

class _PolicyCard extends StatelessWidget {
  final PolicyModel policy;
  final int index;

  const _PolicyCard({required this.policy, required this.index});

  IconData _icon() {
    final t =
        policy.title.toLowerCase() + policy.policyTypeName.toLowerCase();
    if (t.contains('life')) return Icons.favorite_rounded;
    if (t.contains('health') || t.contains('medical'))
      return Icons.local_hospital_rounded;
    if (t.contains('car') || t.contains('vehicle') || t.contains('motor'))
      return Icons.directions_car_rounded;
    if (t.contains('home') || t.contains('property'))
      return Icons.home_rounded;
    if (t.contains('travel')) return Icons.flight_rounded;
    if (t.contains('business') || t.contains('commercial'))
      return Icons.business_center_rounded;
    return Icons.shield_rounded;
  }

  // Strip HTML tags from description
  String _cleanDescription(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final cleanDesc = _cleanDescription(policy.description);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/policies/browse/${policy.id}'),
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
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top: icon + title + premium ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient icon box
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_icon(), color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  // Title + type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.title,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppTextStyles.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (policy.policyTypeName.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            policy.policyTypeName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTextStyles.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Description ───────────────────────────────
            if (cleanDesc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  cleanDesc,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppTextStyles.textSecondaryColor, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // ── Divider ────────────────────────────────────
            Divider(height: 1, color: Theme.of(context).colorScheme.outline),

            // ── Bottom: tags + premium CTA ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  // Tags
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (policy.policySubTypeName != null &&
                            policy.policySubTypeName!.isNotEmpty)
                          _PolicyTag(
                              label: policy.policySubTypeName!,
                              isAccent: false),
                        if (policy.coverageType != null)
                          _PolicyTag(
                              label: policy.coverageType!,
                              isAccent: false),
                        if (policy.liabilityRisk != null)
                          _PolicyTag(
                              label: 'Risk: ${policy.liabilityRisk!}',
                              isAccent: false),
                        if (policy.durationMonths > 0)
                          _PolicyTag(
                              label: '${policy.durationMonths} mo',
                              isAccent: true),
                        if (policy.totalInsuredPerson > 1)
                          _PolicyTag(
                              label:
                                  '${policy.totalInsuredPerson} persons',
                              isAccent: false),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Premium CTA
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppFormatter.formatCurrency(policy.minPremium),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'from / yr',
                        style: AppTextStyles.caption
                            .copyWith(color: AppTextStyles.textHintColor),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => context.push(
                            '/policies/apply/${policy.id}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Apply',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 280.ms)
        .slideY(begin: 0.08, duration: 280.ms);
  }
}

class _PolicyTag extends StatelessWidget {
  final String label;
  final bool isAccent;

  const _PolicyTag({required this.label, required this.isAccent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAccent ? AppColors.accentContainer : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: isAccent ? AppColors.accentDark : AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Category Chip & Icon Helpers ───────────────────────────

IconData _categoryIcon(String name) {
  final t = name.toLowerCase();
  if (t.contains('car') || t.contains('vehicle') || t.contains('motor')) {
    return Icons.directions_car_rounded;
  }
  if (t.contains('health') || t.contains('medic')) {
    return Icons.local_hospital_rounded;
  }
  if (t.contains('life')) {
    return Icons.favorite_rounded;
  }
  if (t.contains('home') || t.contains('prop') || t.contains('fire')) {
    return Icons.home_rounded;
  }
  if (t.contains('travel')) {
    return Icons.flight_rounded;
  }
  return Icons.shield_rounded;
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: isSelected
              ? AppColors.primary
              : isDark
                ? AppColors.darkCard
                : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
              ? AppColors.primary
              : isDark
                ? AppColors.darkBorder
                : AppColors.grey200,
            width: 1.2,
          ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected || isDark ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppTextStyles.textPrimaryColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

