import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.terms'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Text('Effective: January 1, 2024', style: AppTextStyles.bodySmall),
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
      'Acceptance of Terms',
      'By using SafeInsurance, you agree to these Terms of Service. If you do not agree, please do not use the application.',
    ),
    _Section(
      'Use of Service',
      'SafeInsurance is an insurance management platform. You agree to use the service only for lawful purposes and in accordance with these terms.',
    ),
    _Section(
      'Account Responsibility',
      'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
    ),
    _Section(
      'Insurance Policies',
      'Insurance policies are subject to their own terms and conditions. SafeInsurance facilitates policy management but is not the insurer.',
    ),
    _Section(
      'Claims Processing',
      'Claim submissions are reviewed by the insurance company. SafeInsurance facilitates submission but does not guarantee approval.',
    ),
    _Section(
      'Limitation of Liability',
      'SafeInsurance is not liable for any indirect, incidental, or consequential damages arising from the use of this application.',
    ),
    _Section(
      'Termination',
      'We reserve the right to terminate or suspend your account for violations of these terms at our sole discretion.',
    ),
  ];
}

class _Section {
  final String title;
  final String content;
  const _Section(this.title, this.content);
}
