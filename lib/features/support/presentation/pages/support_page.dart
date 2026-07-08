import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'package:dio/dio.dart';

class SupportPage extends ConsumerStatefulWidget {
  const SupportPage({super.key});

  @override
  ConsumerState<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends ConsumerState<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final dio = getIt<Dio>();
      await dio.post(
        ApiEndpoints.contact,
        data: {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'contactNumber': _phoneCtrl.text.trim(),
          'subject': _subjectCtrl.text.trim(),
          'message': _messageCtrl.text.trim(),
        },
      );
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('support.title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Quick links ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    icon: Icons.quiz_rounded,
                    label: 'support.faq'.tr(),
                    color: AppColors.primary,
                    onTap: () => context.push(AppConstants.routeFaq),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    icon: Icons.phone_rounded,
                    label: 'Emergency',
                    color: AppColors.error,
                    onTap: () {/* TODO: launch phone */},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Contact Form ──────────────────────────────
            Text('support.contact_us'.tr(), style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Fill in the form below and we\'ll get back to you shortly.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),

            if (_sent)
              _SuccessMessage()
            else
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'common.name'.tr(),
                      controller: _nameCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          Validators.required(v, fieldName: 'Name'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'auth.email'.tr(),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label:
                          '${AppConstants.appName} Phone (${' common.optional'.tr()})',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'support.subject'.tr(),
                      controller: _subjectCtrl,
                      prefixIcon: Icons.subject_rounded,
                      validator: (v) =>
                          Validators.required(v, fieldName: 'Subject'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'support.message'.tr(),
                      controller: _messageCtrl,
                      maxLines: 5,
                      validator: (v) =>
                          Validators.minLength(v, 10, fieldName: 'Message'),
                      hint: 'Describe your issue or question...',
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'support.send_message'.tr(),
                      onPressed: _send,
                      isLoading: _isLoading,
                      leadingIcon: Icons.send_rounded,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.titleSmall, textAlign: TextAlign.center),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 48),
          const SizedBox(height: 16),
          Text('support.sent_success'.tr(),
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
          const SizedBox(height: 8),
          Text(
            'We\'ll respond to your inquiry within 24 hours.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
