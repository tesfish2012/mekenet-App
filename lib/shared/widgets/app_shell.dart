import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Bottom navigation shell — wraps all main screens
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
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
        splashColor: Colors.white.withOpacity(0.12),
        highlightColor: Colors.white.withOpacity(0.06),
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
                    ? Colors.white.withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.65),
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
                color: isSelected ? AppColors.accent : Colors.transparent,
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
