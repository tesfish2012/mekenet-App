import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _ProfileHeader(
                name: user?.name ?? profile.name,
                email: user?.email ?? profile.email,
                role: user?.role ?? profile.role,
                avatarUrl: profile.profileUrl,
              ),
            ),

            // ── Quick Links ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    _MenuSection(items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'profile.edit_profile'.tr(),
                        onTap: () => context.push(AppConstants.routeEditProfile),
                      ),
                      _MenuItem(
                        icon: Icons.shield_rounded,
                        label: 'policies.my_policies'.tr(),
                        onTap: () => context.go(AppConstants.routePolicies),
                      ),
                      _MenuItem(
                        icon: Icons.assignment_rounded,
                        label: 'claims.my_claims'.tr(),
                        onTap: () => context.go(AppConstants.routeClaims),
                      ),
                      _MenuItem(
                        icon: Icons.payment_rounded,
                        label: 'payments.payment_history'.tr(),
                        onTap: () => context.go(AppConstants.routePayments),
                      ),
                      _MenuItem(
                        icon: Icons.folder_open_rounded,
                        label: 'documents.my_documents'.tr(),
                        onTap: () => context.push(AppConstants.routeDocuments),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    Text('Preferences', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    _MenuSection(items: [
                      _MenuItem(
                        icon: Icons.settings_rounded,
                        label: 'settings.title'.tr(),
                        onTap: () => context.push(AppConstants.routeSettings),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        label: 'notifications.title'.tr(),
                        onTap: () => context.push(AppConstants.routeNotifications),
                      ),
                      _MenuItem(
                        icon: Icons.headset_mic_rounded,
                        label: 'support.title'.tr(),
                        onTap: () => context.push(AppConstants.routeSupport),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    Text('Legal', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    _MenuSection(items: [
                      _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'settings.privacy'.tr(),
                        onTap: () => context.push(AppConstants.routePrivacyPolicy),
                      ),
                      _MenuItem(
                        icon: Icons.description_outlined,
                        label: 'settings.terms'.tr(),
                        onTap: () => context.push(AppConstants.routeTerms),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'settings.about'.tr(),
                        onTap: () => context.push(AppConstants.routeAbout),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Logout
                    AppButton(
                      label: 'auth.logout'.tr(),
                      onPressed: () => _logout(context, ref),
                      variant: AppButtonVariant.danger,
                      leadingIcon: Icons.logout_rounded,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('auth.logout'.tr()),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'auth.logout'.tr(),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }
}

// ── Profile Header ────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

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
        24,
        MediaQuery.of(context).padding.top + 24,
        24,
        32,
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: '${AppConstants.fileBaseUrl}/$avatarUrl',
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _AvatarPlaceholder(name: name),
                        )
                      : _AvatarPlaceholder(name: name),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
              ),
            ],
          ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 16),
          Text(
            name,
            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 10),
          _RoleBadge(role: role).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final r = role.toUpperCase();
    final IconData icon;
    final Color badgeColor;
    final String label;

    switch (r) {
      case 'BROKER':
        icon = Icons.business_center_rounded;
        badgeColor = const Color(0xFFF59E0B);
        label = 'Insurance Broker';
        break;
      case 'AGENT':
        icon = Icons.handshake_rounded;
        badgeColor = const Color(0xFF10B981);
        label = 'Insurance Agent';
        break;
      case 'CORPORATE':
        icon = Icons.corporate_fare_rounded;
        badgeColor = const Color(0xFF818CF8);
        label = 'Corporate Client';
        break;
      case 'ADMIN':
        icon = Icons.admin_panel_settings_rounded;
        badgeColor = const Color(0xFFEF4444);
        label = 'Administrator';
        break;
      default:
        icon = Icons.person_rounded;
        badgeColor = const Color(0xFF38BDF8);
        label = 'Customer';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.6), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  const _AvatarPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
      ),
    );
  }
}

// ── Menu Widgets ──────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(
                  i == 0
                      ? 16
                      : i == items.length - 1
                          ? 16
                          : 0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(item.label, style: AppTextStyles.titleSmall),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.grey400,
                      ),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 56, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
