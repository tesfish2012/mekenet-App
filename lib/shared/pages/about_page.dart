import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.about'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 20),
            Text(
              'SafeInsurance',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 6),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, snap) => Text(
                snap.hasData
                    ? 'Version ${snap.data!.version} (${snap.data!.buildNumber})'
                    : 'Loading...',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: 32),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About the App', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'SafeInsurance is an enterprise-grade mobile application that brings '
                    'all your insurance needs to your fingertips. Manage policies, file '
                    'claims, track payments, and access your digital insurance card — '
                    'all from one secure app.',
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _AboutTile(
                    icon: Icons.email_outlined,
                    label: 'Contact',
                    value: 'support@safeinsurance.com',
                    onTap: () => _launch('mailto:support@safeinsurance.com'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _AboutTile(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    value: 'www.safeinsurance.com',
                    onTap: () => _launch('https://safeinsurance.com'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _AboutTile(
                    icon: Icons.phone_rounded,
                    label: 'Hotline',
                    value: '+251 911 000 000',
                    onTap: () => _launch('tel:+251911000000'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '© 2024 SafeInsurance. All rights reserved.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
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
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodySmall),
                  Text(value, style: AppTextStyles.titleSmall),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}
