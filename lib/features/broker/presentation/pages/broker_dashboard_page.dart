import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/models/broker_dashboard_stats_model.dart';
import '../../data/models/broker_models.dart';
import '../providers/broker_providers.dart';

// ── Route names (used by router) ──────────────────────────
const kBrokerDashRoute = '/broker';
const kBrokerAgreementsRoute = '/broker/agreements';
const kBrokerPoliciesRoute = '/broker/policies';
const kBrokerClaimsRoute = '/broker/claims';
const kBrokerClientsRoute = '/broker/clients';
const kBrokerEndorsementsRoute = '/broker/endorsements';
const kBrokerDocumentsRoute = '/broker/documents';
const kBrokerProfileRoute = '/broker/profile';

// ── Currency formatter ────────────────────────────────────
final _currency = NumberFormat.currency(
  locale: 'en_ET',
  symbol: 'ETB ',
  decimalDigits: 0,
);

String _fmt(double v) => _currency.format(v);

// ╔══════════════════════════════════════════════════════════╗
// ║  BrokerDashboardPage                                     ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerDashboardPage extends ConsumerWidget {
  const BrokerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(brokerDashboardStatsProvider);
    final policiesAsync = ref.watch(brokerPoliciesProvider);
    final claimsAsync = ref.watch(brokerClaimsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(brokerDashboardStatsProvider);
          ref.invalidate(brokerPoliciesProvider);
          ref.invalidate(brokerClaimsProvider);
          ref.invalidate(brokerAgreementsProvider);
          ref.invalidate(brokerClientsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ConnectivityBanner()),

            // ── Header ─────────────────────────────────
            SliverToBoxAdapter(
              child: _BrokerHeader(userName: user?.name ?? 'Broker'),
            ),

            // ── KPI Grid ───────────────────────────────
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (s) => _KpiGrid(stats: s),
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingView(),
                ),
                error: (e, _) => _ErrorTile(message: e.toString()),
              ),
            ),

            // ── Renewal Timeline ───────────────────────
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (s) => _RenewalTimeline(stats: s),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Quick Actions ──────────────────────────
            const SliverToBoxAdapter(child: _QuickActions()),

            // ── Premium Volume ─────────────────────────
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (s) => _PremiumVolumeCard(stats: s),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Recent Policies ────────────────────────
            SliverToBoxAdapter(
              child: policiesAsync.when(
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : _RecentPolicies(policies: list.take(5).toList()),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Recent Claims ──────────────────────────
            SliverToBoxAdapter(
              child: claimsAsync.when(
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : _RecentClaims(claims: list.take(4).toList()),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Brand Footer ───────────────────────────
            const SliverToBoxAdapter(child: _BrokerBrandFooter()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────

class _BrokerHeader extends StatelessWidget {
  final String userName;
  const _BrokerHeader({required this.userName});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.darkGradient,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: greeting + actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _greeting(),
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white60),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.5)),
                          ),
                          child: Text(
                            'BROKER PORTAL',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Notification
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded,
                        color: Colors.white, size: 26),
                    onPressed: () =>
                        context.push(AppConstants.routeNotifications),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
              // Profile
              IconButton(
                icon: const Icon(Icons.account_circle_rounded,
                    color: Colors.white70, size: 26),
                onPressed: () => context.push(kBrokerProfileRoute),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Portfolio teaser card
          GlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business_center_rounded,
                      color: AppColors.accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brokerage Portfolio',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white),
                      ),
                      Text(
                        'Manage clients, policies & agreements',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white38, size: 15),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.15, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

// ── KPI Grid ──────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final BrokerDashboardStatsModel stats;
  const _KpiGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiData(
        label: 'Total Clients',
        value: '${stats.totalClients}',
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
        bg: AppColors.primaryContainer,
      ),
      _KpiData(
        label: 'Active Policies',
        value: '${stats.activePolicies}',
        icon: Icons.shield_rounded,
        color: AppColors.success,
        bg: AppColors.successLight,
      ),
      _KpiData(
        label: 'Open Claims',
        value: '${stats.openClaims}',
        icon: Icons.assignment_rounded,
        color: AppColors.error,
        bg: AppColors.errorLight,
      ),
      _KpiData(
        label: 'Pending Commission',
        value: _fmt(stats.pendingCommissions),
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.accent,
        bg: AppColors.accentContainer,
        small: true,
      ),
      _KpiData(
        label: 'Pending Endorsements',
        value: '${stats.pendingEndorsements}',
        icon: Icons.edit_document,
        color: const Color(0xFF8B5CF6),
        bg: const Color(0xFFF3E8FF),
      ),
      _KpiData(
        label: 'Total Policies',
        value: '${stats.totalPolicies}',
        icon: Icons.folder_copy_rounded,
        color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.primaryLight
          : AppColors.grey700,
        bg: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkCard
          : AppColors.grey100,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Brokerage Overview', style: AppTextStyles.titleLarge),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BROKER METRICS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final d = cards[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: d.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(d.icon, size: 20, color: d.color),
                    ),
                    const Spacer(),
                    Text(
                      d.value,
                      style: (d.small
                              ? AppTextStyles.titleMedium
                              : AppTextStyles.headlineSmall)
                          .copyWith(
                              color: d.color, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(d.label,
                        style: AppTextStyles.labelSmall,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 80 * i))
                  .slideY(begin: 0.15, curve: Curves.easeOut);
            },
          ),
        ],
      ),
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool small;
  const _KpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    this.small = false,
  });
}

// ── Renewal Timeline ──────────────────────────────────────

class _RenewalTimeline extends StatelessWidget {
  final BrokerDashboardStatsModel stats;
  const _RenewalTimeline({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _RenewalBucket(label: 'Next 30 days', count: stats.upcomingRenewals30,
          color: AppColors.error),
      _RenewalBucket(label: 'Next 60 days', count: stats.upcomingRenewals60,
          color: AppColors.warning),
      _RenewalBucket(label: 'Next 90 days', count: stats.upcomingRenewals90,
          color: AppColors.success),
    ];
    final total = (stats.upcomingRenewals90).clamp(1, 9999);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_repeat_rounded,
                      size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text('Upcoming Renewals', style: AppTextStyles.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: items
                  .map((b) => Expanded(
                        child: _RenewalBucketTile(bucket: b, total: total),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),
            // stacked bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: items.map((b) {
                    final ratio = b.count / total;
                    return Flexible(
                      flex: (ratio * 100).round().clamp(1, 100),
                      child: Container(color: b.color),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _RenewalBucket {
  final String label;
  final int count;
  final Color color;
  const _RenewalBucket(
      {required this.label, required this.count, required this.color});
}

class _RenewalBucketTile extends StatelessWidget {
  final _RenewalBucket bucket;
  final int total;
  const _RenewalBucketTile(
      {required this.bucket, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${bucket.count}',
          style: AppTextStyles.headlineSmall
              .copyWith(color: bucket.color, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(bucket.label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        label: 'Policies',
        icon: Icons.shield_rounded,
        color: AppColors.success,
        route: kBrokerPoliciesRoute,
      ),
      _ActionItem(
        label: 'Claims',
        icon: Icons.assignment_rounded,
        color: AppColors.error,
        route: kBrokerClaimsRoute,
      ),
      _ActionItem(
        label: 'Clients',
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
        route: kBrokerClientsRoute,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Access', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: actions.length,
            itemBuilder: (context, i) {
              final a = actions[i];
              return InkWell(
                onTap: () => context.push(a.route),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: a.color.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a.icon, size: 28, color: a.color),
                      const SizedBox(height: 6),
                      Text(
                        a.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: a.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 60 * i))
                  .scale(begin: const Offset(0.9, 0.9));
            },
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

// ── Premium Volume Card ───────────────────────────────────

class _PremiumVolumeCard extends StatelessWidget {
  final BrokerDashboardStatsModel stats;
  const _PremiumVolumeCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final mtd = stats.mtdPremiumVolume;
    final ytd = stats.ytdPremiumVolume;
    final progress = ytd > 0 ? (mtd / ytd).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: AppCard(
        gradient: AppColors.cardGradient,
        hasBorder: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up_rounded,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  'Premium Volume',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _VolumeStat(
                      label: 'Month-to-Date',
                      value: _fmt(mtd),
                      color: AppColors.accentLight),
                ),
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.white24),
                Expanded(
                  child: _VolumeStat(
                      label: 'Year-to-Date',
                      value: _fmt(ytd),
                      color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'MTD as % of YTD',
              style: AppTextStyles.caption
                  .copyWith(color: Colors.white60),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.accentLight),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms);
  }
}

class _VolumeStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _VolumeStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.titleMedium.copyWith(
                color: color, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: Colors.white60),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ── Recent Policies ───────────────────────────────────────

class _RecentPolicies extends StatelessWidget {
  final List<BrokerPolicyModel> policies;
  const _RecentPolicies({required this.policies});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Recent Policies',
            onSeeAll: () => context.push(kBrokerPoliciesRoute),
          ),
          const SizedBox(height: 12),
          ...policies.asMap().entries.map((e) {
            final p = e.value;
            final i = e.key;
            return AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _statusBg(p.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.shield_rounded,
                        size: 18, color: _statusColor(p.status)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.customerName,
                            style: AppTextStyles.titleSmall,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${p.policyTitle}  •  ${p.insuranceNumber}',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip.policyStatus(p.status),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(p.premiumAmount),
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 60 * i))
                .slideX(begin: 0.05);
          }),
        ],
      ),
    );
  }
}

// ── Recent Claims ─────────────────────────────────────────

class _RecentClaims extends StatelessWidget {
  final List<BrokerClaimModel> claims;
  const _RecentClaims({required this.claims});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Recent Claims',
            onSeeAll: () => context.push(kBrokerClaimsRoute),
          ),
          const SizedBox(height: 12),
          ...claims.asMap().entries.map((e) {
            final c = e.value;
            final i = e.key;
            return AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _claimStatusBg(c.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.assignment_rounded,
                        size: 18, color: _claimStatusColor(c.status)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.claimantName,
                            style: AppTextStyles.titleSmall,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${c.claimNumber}  •  ${c.claimDate}',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip.claimStatus(c.status),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(c.claimAmount),
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 60 * i))
                .slideX(begin: 0.05);
          }),
        ],
      ),
    );
  }
}

// ── Brand Footer ──────────────────────────────────────────

class _BrokerBrandFooter extends StatelessWidget {
  const _BrokerBrandFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                padding: const EdgeInsets.all(7),
                child:
                    Image.asset(AppConstants.logoAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.appName,
                        style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(AppConstants.appTagline,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push(AppConstants.routeSupport),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.headset_mic_rounded, size: 16),
                label: const Text('Support',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.18), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded,
                      size: 14, color: Color(0xFF60A5FA)),
                  const SizedBox(width: 6),
                  Text('Licensed & Secure Insurer',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500)),
                ],
              ),
              Text('v${AppConstants.appVersion} • © 2026',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('See all',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}

// ── Error tile ────────────────────────────────────────────

class _ErrorTile extends StatelessWidget {
  final String message;
  const _ErrorTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(message,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.error)),
      ),
    );
  }
}

// ── Status helpers ────────────────────────────────────────

Color _statusColor(String s) {
  return switch (s.toUpperCase()) {
    'ACTIVE' => AppColors.success,
    'PENDING' || 'PENDING_PAYMENT' => AppColors.warning,
    'EXPIRED' => AppColors.error,
    'CANCELLED' => AppColors.grey500,
    _ => AppColors.primary,
  };
}

Color _statusBg(String s) {
  return switch (s.toUpperCase()) {
    'ACTIVE' => AppColors.successLight,
    'PENDING' || 'PENDING_PAYMENT' => AppColors.warningLight,
    'EXPIRED' => AppColors.errorLight,
    _ => AppColors.primaryContainer,
  };
}

Color _claimStatusColor(String s) {
  return switch (s.toUpperCase()) {
    'SUBMITTED' => AppColors.primary,
    'UNDER_REVIEW' => AppColors.warning,
    'APPROVED' => AppColors.success,
    'REJECTED' => AppColors.error,
    'PAID' => AppColors.claimPaid,
    _ => AppColors.grey500,
  };
}

Color _claimStatusBg(String s) {
  return switch (s.toUpperCase()) {
    'SUBMITTED' => AppColors.primaryContainer,
    'UNDER_REVIEW' => AppColors.warningLight,
    'APPROVED' => AppColors.successLight,
    'REJECTED' => AppColors.errorLight,
    'PAID' => AppColors.successLight,
    _ => AppColors.grey100,
  };
}
