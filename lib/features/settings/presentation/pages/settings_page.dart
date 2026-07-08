import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = '';
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final info = await PackageInfo.fromPlatform();
    final bio = await getIt<SecureStorageService>().isBiometricEnabled();
    final pin = await getIt<SecureStorageService>().hasPin();
    setState(() {
      _appVersion = info.version;
      _biometricEnabled = bio;
      _pinEnabled = pin;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final auth = LocalAuthentication();
      final canAuth = await auth.canCheckBiometrics;
      if (!canAuth) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometrics not available on this device.')),
          );
        }
        return;
      }
      final authenticated = await auth.authenticate(
        localizedReason: 'Enable biometric login for SafeInsurance',
      );
      if (!authenticated) return;
    }
    await getIt<SecureStorageService>().setBiometricEnabled(value);
    setState(() => _biometricEnabled = value);
  }

  Future<void> _handlePinToggle(bool value) async {
    if (value) {
      context.push(AppConstants.routeCreatePin);
    } else {
      await getIt<SecureStorageService>().deletePin();
      setState(() => _pinEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ───────────────────────────────────
          _SectionHeader('settings.appearance'.tr()),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: AppColors.accent,
                  title: 'settings.dark_mode'.tr(),
                  trailing: DropdownButton<String>(
                    value: themeMode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      ref.read(themeModeProvider.notifier).state = v;
                      await getIt<PreferencesService>().setThemeMode(v);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  iconColor: AppColors.secondary,
                  title: 'settings.language'.tr(),
                  trailing: DropdownButton<String>(
                    value: language,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      ref.read(languageProvider.notifier).state = v;
                      await context.setLocale(Locale(v));
                      await getIt<PreferencesService>().setLanguage(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Security ─────────────────────────────────────
          _SectionHeader('settings.security'.tr()),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  iconColor: AppColors.primary,
                  title: 'settings.biometrics'.tr(),
                  trailing: Switch.adaptive(
                    value: _biometricEnabled,
                    activeColor: AppColors.primary,
                    onChanged: _toggleBiometric,
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(
                  icon: Icons.pin_rounded,
                  iconColor: AppColors.warning,
                  title: 'settings.pin'.tr(),
                  trailing: Switch.adaptive(
                    value: _pinEnabled,
                    activeColor: AppColors.primary,
                    onChanged: _handlePinToggle,
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(
                  icon: Icons.lock_reset_rounded,
                  iconColor: AppColors.error,
                  title: 'Change Password',
                  onTap: () => context.push(AppConstants.routeForgotPassword),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Notifications ─────────────────────────────────
          _SectionHeader('settings.notifications'.tr()),
          AppCard(
            padding: EdgeInsets.zero,
            child: _SettingsTile(
              icon: Icons.notifications_rounded,
              iconColor: AppColors.success,
              title: 'Push Notifications',
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── About ─────────────────────────────────────────
          _SectionHeader('settings.about'.tr()),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.grey500,
                  title: 'settings.app_version'.tr(),
                  subtitle: 'v$_appVersion',
                  onTap: () => context.push(AppConstants.routeAbout),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: AppColors.grey500,
                  title: 'settings.privacy'.tr(),
                  onTap: () => context.push(AppConstants.routePrivacyPolicy),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.grey500,
                  title: 'settings.terms'.tr(),
                  onTap: () => context.push(AppConstants.routeTerms),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
          color: AppColors.grey500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.grey400,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
