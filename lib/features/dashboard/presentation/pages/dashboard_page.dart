import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
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
    final statsAsync = ref.watch(customerStatsProvider);
    final noticesAsync = ref.watch(latestNoticesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(customerStatsProvider);
          ref.invalidate(latestNoticesProvider);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Connectivity Banner ───────────────────────
            const SliverToBoxAdapter(child: ConnectivityBanner()),

            // ── App Bar / Header ──────────────────────────
            SliverToBoxAdapter(
              child: _DashboardHeader(userName: user?.name ?? ''),
            ),

            // ── Stats Cards ───────────────────────────────
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _StatsGrid(stats: stats),
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
              child: _QuickActions(),
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

            // ── Brand Footer ─────────────────────────────
            const SliverToBoxAdapter(
              child: _DashboardBrandFooter(),
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
  final String userName;

  const _DashboardHeader({required this.userName});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'dashboard.greeting_morning'.tr();
    if (hour < 17) return 'dashboard.greeting_afternoon'.tr();
    return 'dashboard.greeting_evening'.tr();
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
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
                      onPressed: () => context.push(AppConstants.routeNotifications),
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
          // Insurance card teaser
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Insurance Summary',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tap to view all policies',
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
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final dynamic stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: AppTextStyles.titleLarge),
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
                title: 'dashboard.active_policies'.tr(),
                value: '${stats.activeInsurances}',
                icon: Icons.shield_rounded,
                color: AppColors.primary,
                bgColor: AppColors.primaryContainer,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              StatsCard(
                title: 'dashboard.pending_claims'.tr(),
                value: '${stats.pendingClaims}',
                icon: Icons.assignment_rounded,
                color: AppColors.warning,
                bgColor: AppColors.warningLight,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              StatsCard(
                title: 'dashboard.total_premium'.tr(),
                value: AppFormatter.formatCurrency(stats.totalPremium),
                icon: Icons.payments_rounded,
                color: AppColors.success,
                bgColor: AppColors.successLight,
                isSmallText: true,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              StatsCard(
                title: 'Total Claims',
                value: '${stats.totalClaims}',
                icon: Icons.receipt_long_rounded,
                color: AppColors.accent,
                bgColor: AppColors.accentContainer,
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
  @override
  Widget build(BuildContext context) {
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

// ── Professional Brand Footer ─────────────────────────────

class _DashboardBrandFooter extends StatelessWidget {
  const _DashboardBrandFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
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
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(7),
                child: Image.asset(
                  AppConstants.logoAsset,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConstants.appTagline,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push(AppConstants.routeSupport),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.headset_mic_rounded, size: 16),
                label: const Text(
                  'Support',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
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
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 15,
                    color: Color(0xFF60A5FA),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Licensed & Secure Insurer',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                'v${AppConstants.appVersion} • © 2026',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
