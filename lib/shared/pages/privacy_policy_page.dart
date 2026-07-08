import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.privacy'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Text('Last updated: January 1, 2024', style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),
            ..._sections.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        s.content,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _sections = [
    _Section(
      'Information We Collect',
      'We collect information you provide directly to us, such as your name, email address, phone number, and insurance-related information when you create an account or use our services.',
    ),
    _Section(
      'How We Use Your Information',
      'We use the information we collect to provide, maintain, and improve our services, process transactions, send notifications about your policies and claims, and comply with legal obligations.',
    ),
    _Section(
      'Data Security',
      'We implement industry-standard security measures to protect your personal information. All data is encrypted in transit and at rest. We use JWT authentication and secure storage for all sensitive data.',
    ),
    _Section(
      'Data Sharing',
      'We do not sell your personal information. We may share data with insurance partners necessary for policy management, and with law enforcement when required by law.',
    ),
    _Section(
      'Your Rights',
      'You have the right to access, update, or delete your personal information. You may also opt out of marketing communications at any time through the app settings.',
    ),
    _Section(
      'Contact Us',
      'If you have questions about this Privacy Policy, please contact us at privacy@safeinsurance.com.',
    ),
  ];
}

class _Section {
  final String title;
  final String content;
  const _Section(this.title, this.content);
}
