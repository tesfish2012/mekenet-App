import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/injectable_config.dart';
import '../../core/storage/preferences_service.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Compact EN / አማርኛ pill toggle.
/// [onDark] = true when placed on a dark/navy background (login page).
/// [onDark] = false when placed on a light background (settings, profile).
class LanguageToggleButton extends ConsumerWidget {
  final bool onDark;

  const LanguageToggleButton({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    return GestureDetector(
      onTap: () => _showPicker(context, ref, current),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: onDark
              ? Colors.white.withOpacity(0.15)
              : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: onDark
                ? Colors.white.withOpacity(0.35)
                : AppColors.primary.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current == 'am' ? '🇪🇹' : '🇬🇧',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(width: 6),
            Text(
              current == 'am' ? 'አማርኛ' : 'EN',
              style: AppTextStyles.labelMedium.copyWith(
                color: onDark ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: onDark ? Colors.white70 : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPicker(
      BuildContext context, WidgetRef ref, String current) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(
        current: current,
        onSelected: (code) async {
          ref.read(languageProvider.notifier).state = code;
          await getIt<PreferencesService>().setLanguage(code);
        },
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────

class _LanguagePickerSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelected;

  const _LanguagePickerSheet({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.language_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'settings.language'.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _LangOption(
            flag: '🇬🇧',
            label: 'English',
            sublabel: 'English',
            code: 'en',
            isSelected: current == 'en',
            onTap: () {
              Navigator.pop(context);
              onSelected('en');
            },
          ),
          const SizedBox(height: 10),
          _LangOption(
            flag: '🇪🇹',
            label: 'አማርኛ',
            sublabel: 'Amharic',
            code: 'am',
            isSelected: current == 'am',
            onTap: () {
              Navigator.pop(context);
              onSelected('am');
            },
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final String sublabel;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.08)
                    : AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppTextStyles.textPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppTextStyles.textSecondaryColor),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
