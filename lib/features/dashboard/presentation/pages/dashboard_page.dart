import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../features/broker/presentation/pages/broker_dashboard_page.dart';
import '../../../../features/agent/presentation/pages/agent_dashboard_page.dart';
import '../../../../features/policies/data/models/policy_model.dart';
import '../../../../features/policies/presentation/providers/policies_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_action_button.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // Agents get their dedicated dashboard.
    if (user?.isAgent == true) {
      return const AgentDashboardPage();
    }

    // Broker users get their dedicated portal dashboard
    if (user?.isBroker == true) {
      return const BrokerDashboardPage();
    }

    final isAgentOrBroker = user?.isAgentOrBroker ?? false;
    final customerStatsAsync =
        isAgentOrBroker ? null : ref.watch(customerStatsProvider);
    final agentStatsAsync =
        isAgentOrBroker ? ref.watch(agentStatsProvider) : null;
    final policyTypes = ref.watch(policyTypesProvider).value ?? const <PolicyTypeModel>[];
    final noticesAsync = ref.watch(latestNoticesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (isAgentOrBroker) {
            ref.invalidate(agentStatsProvider);
          } else {
            ref.invalidate(customerStatsProvider);
          }
          ref.invalidate(latestNoticesProvider);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Connectivity Banner ───────────────────────
            const SliverToBoxAdapter(child: ConnectivityBanner()),

            // ── App Bar / Header ──────────────────────────
            SliverToBoxAdapter(
              child: _DashboardHeader(user: user),
            ),

            // ── Stats Cards ───────────────────────────────
            SliverToBoxAdapter(
              child: isAgentOrBroker
                  ? agentStatsAsync!.when(
                      data: (stats) => _AgentBrokerStatsGrid(
                        stats: stats,
                        isBroker: user?.isBroker ?? false,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: LoadingView(),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(e.toString()),
                      ),
                    )
                  : customerStatsAsync!.when(
                      data: (stats) => _StatsGrid(
                        stats: stats,
                        policyTypes: policyTypes,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: LoadingView(),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(e.toString()),
                      ),
                    ),
            ),

            // ── Quick Actions ─────────────────────────────
            SliverToBoxAdapter(
              child: _QuickActions(isAgentOrBroker: isAgentOrBroker),
            ),

            // ── Notices / News ────────────────────────────
            SliverToBoxAdapter(
              child: noticesAsync.when(
                data: (notices) => notices.isEmpty
                    ? const SizedBox.shrink()
                    : _NoticesSection(notices: notices),
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

// ── Header ────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final dynamic user;

  const _DashboardHeader({required this.user});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'dashboard.greeting_morning'.tr();
    if (hour < 17) return 'dashboard.greeting_afternoon'.tr();
    return 'dashboard.greeting_evening'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final isBroker = user?.isBroker == true;
    final isAgent = user?.isAgent == true;
    final isCorporate = user?.isCorporate == true;
    final roleName = isBroker
        ? 'BROKER PORTAL'
        : (isAgent
            ? 'AGENT PORTAL'
            : (isCorporate ? 'CORPORATE PORTAL' : 'CUSTOMER'));

    final roleColor = isBroker
        ? const Color(0xFFF59E0B)
        : (isAgent
            ? const Color(0xFF10B981)
            : (isCorporate ? const Color(0xFF6366F1) : const Color(0xFF38BDF8)));

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _greeting(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: roleColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            roleName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: roleColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'Welcome',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Notification bell
              Consumer(
                builder: (context, ref, _) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
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
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
          // Role-tailored summary card teaser
          GestureDetector(
            onTap: () => context.push(AppConstants.routePolicies),
            child: GlassCard(
              child: Row(
                children: [
                  Icon(
                    isBroker
                        ? Icons.business_center_rounded
                        : (isAgent
                            ? Icons.handshake_rounded
                            : Icons.shield_rounded),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBroker
                              ? 'Brokerage Portfolio Summary'
                              : (isAgent
                                  ? 'Agent Performance Summary'
                                  : (isCorporate
                                      ? 'Corporate Insurance Portfolio'
                                      : 'Your Insurance Summary')),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isBroker
                              ? 'Tap to manage client policies & quotes'
                              : (isAgent
                                  ? 'Tap to view assigned client policies'
                                  : 'Tap to view all policies'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }
}

// ── Customer Stats Grid ───────────────────────────────────

class _StatsGrid extends ConsumerStatefulWidget {
  final dynamic stats;
  final List<PolicyTypeModel> policyTypes;

  const _StatsGrid({required this.stats, required this.policyTypes});

  @override
  ConsumerState<_StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends ConsumerState<_StatsGrid> {
  bool _expanded = false;

  static const int _collapsedMax = 6;

  IconData _categoryIcon(String label) {
    final name = label.toLowerCase();
    if (name.contains('vehicle') || name.contains('motor') || name.contains('car')) {
      return Icons.directions_car_rounded;
    }
    if (name.contains('life')) return Icons.favorite_rounded;
    if (name.contains('health') || name.contains('medical')) {
      return Icons.local_hospital_rounded;
    }
    if (name.contains('travel')) return Icons.flight_rounded;
    if (name.contains('home') || name.contains('property')) {
      return Icons.home_rounded;
    }
    return Icons.shield_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final policyTypes = widget.policyTypes;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (policyTypes.isEmpty) return const SizedBox.shrink();

    final hasMore = policyTypes.length > _collapsedMax;
    final visibleTypes =
        _expanded ? policyTypes : policyTypes.take(_collapsedMax).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ─────────────────────────────
          Row(
            children: [
              Text('Policy by Category', style: AppTextStyles.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${policyTypes.length} types',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Decorated 2-column grid ────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: _buildGrid(
                policyTypes.take(_collapsedMax).toList(), context),
            secondChild: _buildGrid(policyTypes, context),
          ),

          // ── Toggle button (only when >6 types) ────────
          if (hasMore) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                    color: _expanded
                      ? (isDark ? AppColors.darkCard : AppColors.primaryContainer)
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 280),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _expanded
                          ? 'Show Less'
                          : 'See All  (+${policyTypes.length - _collapsedMax} more)',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(List<PolicyTypeModel> types, BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: types.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final type = types[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isSelected = ref.watch(selectedPolicyTypeIdProvider) == type.id;

        return GestureDetector(
          onTap: () {
            final current = ref.read(selectedPolicyTypeIdProvider);
            ref.read(selectedPolicyTypeIdProvider.notifier).state =
                current == type.id ? null : type.id;
            ref.read(policySearchQueryProvider.notifier).state = '';
            context.push('/policies/browse');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    )
                  : null,
                color: isSelected
                  ? null
                  : isDark
                    ? AppColors.darkCard
                    : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                  ? AppColors.primary
                  : isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary
                      .withOpacity(isSelected ? 0.18 : 0.05),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                      : isDark
                        ? AppColors.primaryLight
                        : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    _categoryIcon(type.name),
                    size: 16,
                    color: isSelected || isDark
                      ? Colors.white
                      : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppTextStyles.textPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tap to browse',
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? Colors.white70
                              : AppTextStyles.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: isSelected
                      ? Colors.white70
                      : isDark
                        ? AppColors.darkTextHint
                        : AppColors.grey400,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Agent & Broker Stats Grid ─────────────────────────────

class _AgentBrokerStatsGrid extends StatelessWidget {
  final dynamic stats;
  final bool isBroker;

  const _AgentBrokerStatsGrid({
    required this.stats,
    required this.isBroker,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBroker ? 'Brokerage Overview' : 'Agent Performance',
                style: AppTextStyles.titleLarge,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBroker
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isBroker ? 'BROKER METRICS' : 'AGENT METRICS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isBroker
                        ? const Color(0xFF92400E)
                        : const Color(0xFF065F46),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              StatsCard(
                title: 'Total Clients',
                value: '${stats.totalClients}',
                icon: Icons.people_alt_rounded,
                color: AppColors.primary,
                bgColor: AppColors.primaryContainer,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              StatsCard(
                title: 'Active Policies',
                value: '${stats.activePolicies}',
                icon: Icons.shield_rounded,
                color: AppColors.success,
                bgColor: AppColors.successLight,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              StatsCard(
                title: 'Pending Policies',
                value: '${stats.pendingPolicies}',
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
                bgColor: AppColors.warningLight,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              StatsCard(
                title: isBroker ? 'Total Commission' : 'Total Premium',
                value: AppFormatter.formatCurrency(
                  isBroker
                      ? stats.totalCommission
                      : (stats.totalPremium > 0
                          ? stats.totalPremium
                          : stats.totalCommission),
                ),
                icon: isBroker
                    ? Icons.account_balance_wallet_rounded
                    : Icons.payments_rounded,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
                isSmallText: true,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final bool isAgentOrBroker;

  const _QuickActions({this.isAgentOrBroker = false});

  @override
  Widget build(BuildContext context) {
    if (isAgentOrBroker) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('dashboard.quick_actions'.tr(), style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    label: 'Browse Policies',
                    icon: Icons.add_shopping_cart_rounded,
                    color: AppColors.primary,
                    onTap: () => context.push(AppConstants.routeBrowsePolicies),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButton(
                    label: 'Client Policies',
                    icon: Icons.shield_rounded,
                    color: AppColors.success,
                    onTap: () => context.push(AppConstants.routePolicies),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButton(
                    label: 'Claims',
                    icon: Icons.assignment_rounded,
                    color: AppColors.warning,
                    onTap: () => context.push(AppConstants.routeClaims),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButton(
                    label: 'Payments',
                    icon: Icons.payment_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.push(AppConstants.routePayments),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('dashboard.quick_actions'.tr(), style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  label: 'dashboard.new_claim'.tr(),
                  icon: Icons.add_circle_rounded,
                  color: AppColors.error,
                  onTap: () => context.push('/claims/new'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  label: 'dashboard.pay_premium'.tr(),
                  icon: Icons.payment_rounded,
                  color: AppColors.success,
                  onTap: () => context.push(AppConstants.routePayments),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  label: 'dashboard.view_policy'.tr(),
                  icon: Icons.shield_rounded,
                  color: AppColors.primary,
                  onTap: () => context.push(AppConstants.routePolicies),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  label: 'dashboard.get_support'.tr(),
                  icon: Icons.headset_mic_rounded,
                  color: AppColors.secondary,
                  onTap: () => context.push(AppConstants.routeSupport),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Notices ───────────────────────────────────────────────

class _NoticesSection extends StatelessWidget {
  final List<Map<String, dynamic>> notices;

  const _NoticesSection({required this.notices});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('dashboard.latest_news'.tr(), style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          ...notices.map(
            (notice) => AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (notice['title'] as String?) ?? '',
                          style: AppTextStyles.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (notice['description'] as String?) ?? '',
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


