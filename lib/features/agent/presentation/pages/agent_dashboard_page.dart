import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../features/dashboard/data/models/dashboard_stats_model.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_view.dart';

/// Dedicated dashboard for insurance agents.
class AgentDashboardPage extends ConsumerWidget {
  const AgentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(agentStatsProvider);
    final noticesAsync = ref.watch(latestNoticesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(agentStatsProvider);
          ref.invalidate(latestNoticesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ConnectivityBanner()),
            SliverToBoxAdapter(child: _AgentHeader(name: user?.name ?? 'Agent')),
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _AgentOverview(stats: stats),
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingView(),
                ),
                error: (_, __) => const _ErrorCard(
                  message: 'Unable to load agent statistics. Pull down to retry.',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _SectionHeading(title: 'Quick actions')),
            const SliverToBoxAdapter(child: _AgentQuickActions()),
            const SliverToBoxAdapter(child: _SectionHeading(title: 'Latest notices')),
            SliverToBoxAdapter(
              child: noticesAsync.when(
                data: (notices) => notices.isEmpty
                    ? const _EmptyNotices()
                    : Column(
                        children: notices.map((notice) {
                          final title = (notice['title'] ?? notice['subject'] ?? 'Notice').toString();
                          final body = (notice['message'] ?? notice['description'] ?? '').toString();
                          return Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.lightBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.campaign_outlined, color: AppColors.accent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: AppTextStyles.titleSmall),
                                      if (body.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(body, style: AppTextStyles.bodySmall),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _AgentHeader extends StatelessWidget {
  final String name;
  const _AgentHeader({required this.name});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.darkGradient,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text('AGENT PORTAL', style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent, fontWeight: FontWeight.w800, letterSpacing: 1.1,
              )),
              const Spacer(),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => context.push(AppConstants.routeNotifications),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_greeting, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 3),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Manage your clients, policies and commissions.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _AgentOverview extends StatelessWidget {
  final AgentStatsModel stats;
  const _AgentOverview({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricData('My clients', stats.totalClients, Icons.people_alt_rounded, const Color(0xFF4263EB)),
      _MetricData('Total policies', stats.totalPolicies, Icons.shield_rounded, AppColors.primary),
      _MetricData('Active policies', stats.activePolicies, Icons.verified_rounded, AppColors.success),
      _MetricData('Pending policies', stats.pendingPolicies, Icons.hourglass_top_rounded, AppColors.accentDark),
      _MetricData('Total claims', stats.totalClaims, Icons.assignment_rounded, const Color(0xFF7C3AED)),
      _MetricData('Pending claims', stats.pendingClaims, Icons.pending_actions_rounded, AppColors.error),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.cardGradient),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.16), blurRadius: 16, offset: const Offset(0, 7))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total commission', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('ETB ${_formatAmount(stats.totalCommission)}',
                        style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Premium volume: ETB ${_formatAmount(stats.totalPremium)}',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionHeading(title: 'Performance overview', inline: true),
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.42,
            ),
            itemBuilder: (context, index) => _MetricCard(data: items[index]),
          ),
        ],
      ),
    );
  }
}

String _formatAmount(double amount) {
  final whole = amount.round().toString();
  return whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

class _MetricData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _MetricData(this.label, this.value, this.icon, this.color);
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.025), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: data.color.withOpacity(.10), borderRadius: BorderRadius.circular(11)),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          Text('${data.value}', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
          Text(data.label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
        ],
      ),
    );
  }
}

class _AgentQuickActions extends StatelessWidget {
  const _AgentQuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Customers', Icons.people_alt_outlined, '/agent/customers'),
      _ActionData('Policies', Icons.shield_outlined, AppConstants.routePolicies),
      _ActionData('Claims', Icons.assignment_outlined, AppConstants.routeClaims),
      _ActionData('Payments', Icons.payments_outlined, AppConstants.routePayments),
      _ActionData('My profile', Icons.person_outline_rounded, AppConstants.routeProfile),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: GridView.builder(
        itemCount: actions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 10, childAspectRatio: .9,
        ),
        itemBuilder: (context, index) {
          final action = actions[index];
          return Material(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go(action.route),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.icon, color: AppColors.primary, size: 23),
                    const SizedBox(height: 8),
                    Text(action.label, textAlign: TextAlign.center, maxLines: 2,
                      style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionData {
  final String label;
  final IconData icon;
  final String route;
  const _ActionData(this.label, this.icon, this.route);
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final bool inline;
  const _SectionHeading({required this.title, this.inline = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: inline ? EdgeInsets.zero : const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
    );
  }
}

class _EmptyNotices extends StatelessWidget {
  const _EmptyNotices();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            SizedBox(width: 10),
            Expanded(child: Text('You are all caught up. No new notices.')),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(14)),
        child: Text(message, style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}
