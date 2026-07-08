import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('support.faq'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FaqItem(
            question: 'How do I file a claim?',
            answer:
                'Go to the Claims tab, tap "New Claim", select your policy, fill in the details, and submit. You can track your claim status in real-time.',
          ),
          _FaqItem(
            question: 'How can I view my policy documents?',
            answer:
                'Navigate to your policy details and tap "Digital Card" to view your insurance certificate. You can also download a PDF copy.',
          ),
          _FaqItem(
            question: 'What payment methods are accepted?',
            answer:
                'We accept bank transfers, Stripe, and manual payments. Upload your payment receipt for verification.',
          ),
          _FaqItem(
            question: 'How do I renew my policy?',
            answer:
                'You\'ll receive a renewal reminder before expiry. Simply go to your policy and tap "Renew Policy" to continue coverage.',
          ),
          _FaqItem(
            question: 'Can I add beneficiaries to my policy?',
            answer:
                'Yes! Contact support or visit your policy details to manage insured persons and nominees.',
          ),
          _FaqItem(
            question: 'How do I contact customer support?',
            answer:
                'Tap on Support in your profile or use the in-app contact form. Our team responds within 24 hours.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          title: Text(widget.question, style: AppTextStyles.titleSmall),
          trailing: Icon(
            _isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (v) => setState(() => _isExpanded = v),
          children: [
            Text(widget.answer, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
