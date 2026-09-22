import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/policies_provider.dart';
import '../../data/models/policy_model.dart';
import 'policy_payment_page.dart';

class ApplyPolicyPage extends ConsumerStatefulWidget {
  final int policyId;
  final int? selectedPricingIndex;

  const ApplyPolicyPage({
    super.key,
    required this.policyId,
    this.selectedPricingIndex,
  });

  @override
  ConsumerState<ApplyPolicyPage> createState() => _ApplyPolicyPageState();
}

class _ApplyPolicyPageState extends ConsumerState<ApplyPolicyPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  late int _selectedPricingIndex;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedPricingIndex = widget.selectedPricingIndex ?? 0;
    _startDate = DateTime.now();
    _endDate = DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
  }

  void _updateEndDate(int months) {
    setState(() {
      _endDate = DateTime(
        _startDate.year,
        _startDate.month + months,
        _startDate.day,
      );
    });
  }

  Future<void> _pickStartDate(int months) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = DateTime(
          picked.year,
          picked.month + (months > 0 ? months : 12),
          picked.day,
        );
      });
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _continue(PolicyModel policy) {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pricing = policy.pricing.isNotEmpty &&
            _selectedPricingIndex < policy.pricing.length
        ? policy.pricing[_selectedPricingIndex]
        : null;

    final double amount = pricing != null
        ? ((pricing['price'] as num?)?.toDouble() ?? policy.minPremium)
        : policy.minPremium;

    final int months = pricing != null
        ? ((pricing['months'] as num?)?.toInt() ?? 12)
        : (policy.durationMonths > 0 ? policy.durationMonths : 12);

    final String planLabel = pricing != null
        ? (pricing['termsDuration'] as String? ?? '$months months')
        : (policy.durationMonths > 0 ? '${policy.durationMonths} months' : '12 months');

    context.push(
      '/policies/payment',
      extra: PolicyPaymentArgs(
        policyId: policy.id,
        policyTitle: policy.title,
        planLabel: planLabel,
        amount: amount,
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
        policyTerm: months,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final policyAsync = ref.watch(policyByIdProvider(widget.policyId));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'policies.apply_policy'.tr(),
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: policyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (policy) => _buildForm(context, policy),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PolicyModel policy) {
    final pricing = policy.pricing;
    final selectedTier =
        pricing.isNotEmpty ? pricing[_selectedPricingIndex] : null;

    final double displayAmount = selectedTier != null
        ? ((selectedTier['price'] as num?)?.toDouble() ?? policy.minPremium)
        : policy.minPremium;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Policy summary banner ─────────────────────
            AppCard(
              gradient: AppColors.primaryGradient,
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.title,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (policy.policyTypeName.isNotEmpty)
                          Text(
                            policy.policyTypeName,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Select pricing plan ───────────────────────
            if (pricing.isNotEmpty) ...[
              Text('Choose Plan', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              ...pricing.asMap().entries.map((entry) {
                final i = entry.key;
                final tier = entry.value;
                final isSelected = _selectedPricingIndex == i;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPricingIndex = i;
                      final m = (tier['months'] as num?)?.toInt() ?? 12;
                      _updateEndDate(m);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color:
                              isSelected ? Colors.white : AppColors.grey400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tier['termsDuration'] as String? ??
                                '${tier['months']} months',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        // Amount read-only from policy — not editable
                        Text(
                          AppFormatter.formatCurrency(
                              (tier['price'] as num).toDouble()),
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // ── Coverage Period ───────────────────────────
            Text('Coverage Period', style: AppTextStyles.titleMedium),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                final months = selectedTier != null
                    ? ((selectedTier['months'] as num?)?.toInt() ?? 12)
                    : (policy.durationMonths > 0 ? policy.durationMonths : 12);
                _pickStartDate(months);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 22, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Date',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.grey500)),
                          const SizedBox(height: 2),
                          Text(_formatDate(_startDate),
                              style: AppTextStyles.titleSmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppColors.grey400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Date',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.grey500)),
                          const SizedBox(height: 2),
                          Text(_formatDate(_endDate),
                              style: AppTextStyles.titleSmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_calendar_rounded,
                        size: 18, color: AppColors.grey400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Notes (optional) ──────────────────────────
            Text('Notes (optional)', style: AppTextStyles.titleMedium),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // ── Order summary (read-only amounts) ─────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _SummaryRow(label: 'Policy', value: policy.title),
                  if (selectedTier != null)
                    _SummaryRow(
                      label: 'Plan',
                      value: selectedTier['termsDuration'] as String? ??
                          '${selectedTier['months']} months',
                    ),
                  _SummaryRow(
                    label: 'Period',
                    value: '${_formatDate(_startDate)} → ${_formatDate(_endDate)}',
                  ),
                  if (policy.sumAssuredDefault > 0)
                    _SummaryRow(
                      label: 'Sum Assured',
                      value: AppFormatter.formatCurrency(
                          policy.sumAssuredDefault),
                    ),
                  const Divider(height: 20),
                  _SummaryRow(
                    label: 'Premium Amount',
                    value: AppFormatter.formatCurrency(displayAmount),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Terms agreement ───────────────────────────
            GestureDetector(
              onTap: () =>
                  setState(() => _agreedToTerms = !_agreedToTerms),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _agreedToTerms
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _agreedToTerms
                            ? AppColors.primary
                            : AppColors.grey300,
                        width: 1.5,
                      ),
                    ),
                    child: _agreedToTerms
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'I agree to the Terms & Conditions and Privacy Policy of this insurance product.',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.lightTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Continue → Payment page ───────────────────
            AppButton(
              label:
                  'Continue  —  ${AppFormatter.formatCurrency(displayAmount)}',
              onPressed: () => _continue(policy),
              leadingIcon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Cancel',
              onPressed: () => context.pop(),
              variant: AppButtonVariant.outlined,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Summary row widget ────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
          ),
          const Spacer(),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )
                : AppTextStyles.bodySmall.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
