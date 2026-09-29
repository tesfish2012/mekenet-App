import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/policies_provider.dart';
import '../../data/models/policy_model.dart';

class BrowsePolicyDetailPage extends ConsumerStatefulWidget {
  final int policyId;
  const BrowsePolicyDetailPage({super.key, required this.policyId});

  @override
  ConsumerState<BrowsePolicyDetailPage> createState() =>
      _BrowsePolicyDetailPageState();
}

class _BrowsePolicyDetailPageState
    extends ConsumerState<BrowsePolicyDetailPage> {
  int _selectedPricingIndex = 0;

  IconData _policyIcon(PolicyModel policy) {
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

  String _cleanHtml(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final policyAsync = ref.watch(policyByIdProvider(widget.policyId));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: policyAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Policy Details')),
          body: Center(child: Text(e.toString())),
        ),
        data: (policy) => _buildContent(context, policy),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PolicyModel policy) {
    final pricing = policy.pricing;

    return CustomScrollView(
      slivers: [
        // ── Hero app bar ─────────────────────────────────
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          elevation: 0,
          backgroundColor: AppColors.secondary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(_policyIcon(policy),
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  policy.title,
                                  style: AppTextStyles.titleLarge
                                      .copyWith(color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (policy.policyTypeName.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    policy.policyTypeName,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: Colors.white70),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Quick stats row
                      Row(
                        children: [
                          _HeroStatBadge(
                            icon: Icons.attach_money_rounded,
                            label:
                                'From ${AppFormatter.formatCurrency(policy.minPremium)}',
                          ),
                          if (policy.coverageType != null) ...[
                            const SizedBox(width: 8),
                            _HeroStatBadge(
                                icon: Icons.verified_rounded,
                                label: policy.coverageType!),
                          ],
                          if (policy.durationMonths != null &&
                              policy.durationMonths > 0) ...[
                            const SizedBox(width: 8),
                            _HeroStatBadge(
                              icon: Icons.calendar_month_rounded,
                              label: '${policy.durationMonths} months',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Description ────────────────────────────
              if (_cleanHtml(policy.description).isNotEmpty) ...[
                _SectionHeader(title: 'About this Policy'),
                AppCard(
                  child: Text(
                    _cleanHtml(policy.description),
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.65),
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 20),
              ],

              // ── Pricing tiers ───────────────────────────
              if (pricing.isNotEmpty) ...[
                _SectionHeader(title: 'Choose Your Plan'),
                ...pricing.asMap().entries.map((entry) {
                  final i = entry.key;
                  final tier = entry.value;
                  final isSelected = _selectedPricingIndex == i;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPricingIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          // Duration badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${tier['months']}m',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              tier['termsDuration'] as String? ??
                                  '${tier['months']} months',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatter.formatCurrency(
                                    (tier['price'] as num?)?.toDouble() ?? 0.0),
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Selected',
                                    style:
                                        AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],

              // ── Policy info ─────────────────────────────
              _SectionHeader(title: 'Policy Details'),
              AppCard(
                child: Column(
                  children: [
                    if (policy.policySubTypeName != null)
                      _DetailRow(
                          label: 'Sub Type',
                          value: policy.policySubTypeName!),
                    if (policy.coverageType != null)
                      _DetailRow(
                          label: 'policies.coverage_type'.tr(),
                          value: policy.coverageType!),
                    if (policy.liabilityRisk != null)
                      _DetailRow(
                          label: 'policies.liability_risk'.tr(),
                          value: policy.liabilityRisk!),
                    _DetailRow(
                        label: 'Insured Persons',
                        value:
                            '${policy.totalInsuredPerson} person(s)'),
                    if (policy.maxSumAssured > 0)
                      _DetailRow(
                          label: 'Max Sum Assured',
                          value: AppFormatter.formatCurrency(
                              policy.maxSumAssured)),
                    if (policy.taxPercent > 0)
                      _DetailRow(
                          label: 'Tax',
                          value: '${policy.taxPercent}%'),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
              const SizedBox(height: 20),

              // ── Terms ───────────────────────────────────
              if (_cleanHtml(policy.termsConditions).isNotEmpty) ...[
                _SectionHeader(title: 'Terms & Conditions'),
                AppCard(
                  child: Text(
                    _cleanHtml(policy.termsConditions),
                    style: AppTextStyles.bodySmall
                        .copyWith(height: 1.65, color: AppColors.grey600),
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                const SizedBox(height: 20),
              ],

              // ── Apply CTA ───────────────────────────────
              AppButton(
                label: pricing.isNotEmpty
                    ? 'Apply — ${AppFormatter.formatCurrency(((pricing[_selectedPricingIndex]['price'] as num?)?.toDouble() ?? 0.0))}'
                    : 'Apply Now',
                onPressed: () {
                  context.push(
                    '/policies/apply/${policy.id}?pricingIndex=$_selectedPricingIndex',
                  );
                },
                leadingIcon: Icons.check_circle_rounded,
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────

class _HeroStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall
                .copyWith(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: AppTextStyles.titleMedium),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.grey500)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.titleSmall
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
