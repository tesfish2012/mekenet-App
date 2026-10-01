import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../theme/app_colors.dart';

/// Bottom navigation shell — wraps all main screens
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isBroker = user?.isBroker ?? false;
    final isAgent = user?.isAgent ?? false;

    return Scaffold(
      body: child,
      bottomNavigationBar: isBroker
          ? const _BrokerBottomNav()
          : isAgent
              ? const _AgentBottomNav()
              : const _CustomerBottomNav(),
    );
  }
}

// ── Customer / Agent bottom nav (unchanged) ───────────────

class _CustomerBottomNav extends StatelessWidget {
  const _CustomerBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final items = [
      _NavItem(icon: Icons.dashboard_rounded, label: 'dashboard.title'.tr(), path: '/dashboard'),
      _NavItem(icon: Icons.shield_rounded, label: 'policies.title'.tr(), path: '/policies'),
      _NavItem(icon: Icons.assignment_rounded, label: 'claims.title'.tr(), path: '/claims'),
      _NavItem(icon: Icons.payment_rounded, label: 'payments.title'.tr(), path: '/payments'),
      _NavItem(icon: Icons.person_rounded, label: 'profile.title'.tr(), path: '/profile'),
    ];

    int selectedIndex = items.indexWhere(
      (item) => location.startsWith(item.path),
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return _NavBar(items: items, selectedIndex: selectedIndex);
  }
}

// ── Agent bottom nav ──────────────────────────────────────
// Keep agent navigation focused on day-to-day policy servicing.
// Each item uses an existing registered route.
class _AgentBottomNav extends StatelessWidget {
  const _AgentBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final items = [
      _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
      _NavItem(icon: Icons.shield_rounded, label: 'Policies', path: '/policies'),
      _NavItem(icon: Icons.assignment_rounded, label: 'Claims', path: '/claims'),
      _NavItem(icon: Icons.folder_open_rounded, label: 'Documents', path: '/documents'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
    ];

    int selectedIndex = items.indexWhere(
      (item) => location.startsWith(item.path),
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return _NavBar(items: items, selectedIndex: selectedIndex);
  }
}

// ── Broker bottom nav (no Payments) ──────────────────────

class _BrokerBottomNav extends StatelessWidget {
  const _BrokerBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final items = [
      _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
      _NavItem(icon: Icons.people_alt_rounded, label: 'Clients', path: '/broker/clients'),
      _NavItem(icon: Icons.shield_rounded, label: 'Policies', path: '/broker/policies'),
      _NavItem(icon: Icons.assignment_rounded, label: 'Claims', path: '/broker/claims'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/broker/profile'),
    ];

    int selectedIndex = items.indexWhere(
      (item) => location.startsWith(item.path),
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return _NavBar(items: items, selectedIndex: selectedIndex);
  }
}

// ── Shared nav bar renderer ───────────────────────────────

class _NavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  const _NavBar({required this.items, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBB03B),
            Color(0xFFF5A623),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4891A).withOpacity(0.45),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4891A).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;
              return Expanded(
                child: _NavButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => context.go(item.path),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withOpacity(0.15),
        highlightColor: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                item.icon,
                size: 21,
                color: isSelected
                    ? Colors.white
                    : AppColors.primary.withOpacity(0.72),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.72),
                letterSpacing: isSelected ? 0.2 : 0,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isSelected ? 14 : 0,
              height: 2.5,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
