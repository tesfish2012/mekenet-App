import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/policies_provider.dart';
import '../../data/models/policy_model.dart';

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
  final _sumAssuredCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late int _selectedPricingIndex;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSubmitting = false;
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
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _sumAssuredCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(PolicyModel policy) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final pricing = policy.pricing.isNotEmpty &&
              _selectedPricingIndex < policy.pricing.length
          ? policy.pricing[_selectedPricingIndex]
          : null;

      final double premiumAmount = pricing != null
          ? ((pricing['price'] as num?)?.toDouble() ?? policy.minPremium)
          : policy.minPremium;

      final int policyTerm = pricing != null
          ? ((pricing['months'] as num?)?.toInt() ?? policy.durationMonths)
          : (policy.durationMonths > 0 ? policy.durationMonths : 12);

      final double sumAssured = _sumAssuredCtrl.text.isNotEmpty
          ? double.tryParse(_sumAssuredCtrl.text) ?? policy.sumAssuredDefault
          : (policy.sumAssuredDefault > 0
              ? policy.sumAssuredDefault
              : policy.maxSumAssured);

      final request = ApplyPolicyRequest(
        customerId: 0,
        policyId: policy.id,
        agentId: 0,
        agentCommission: policy.agentCommissionPercent,
        sumAssured: sumAssured,
        premiumAmount: premiumAmount,
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
        policyTerm: policyTerm,
        statusLabel: 'PENDING',
        notes: _notesCtrl.text.trim(),
      );

      final dio = getIt<Dio>();
      await dio.post(
        ApiEndpoints.portalInsurances,
        data: request.toJson(),
      );

      if (mounted) {
        // Invalidate my insurances so it refreshes
        ref.invalidate(myInsurancesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Policy application submitted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Go to my policies
        context.go('/policies');
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg = (e.response?.data as Map?)?['message'] as String? ??
            e.message ??
            'Submission failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (policy) => _buildForm(context, policy),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PolicyModel policy) {
    final pricing = policy.pricing;
    final selectedTier =
        pricing.isNotEmpty ? pricing[_selectedPricingIndex] : null;

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
                      final months = (tier['months'] as num?)?.toInt() ?? 12;
                      _updateEndDate(months);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.white,
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
                                color: AppColors.primary
                                    .withOpacity(0.2),
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
                          color: isSelected
                              ? Colors.white
                              : AppColors.grey400,
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
                          Text(
                            'Start Date',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.grey500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(_startDate),
                            style: AppTextStyles.titleSmall,
                          ),
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
                          Text(
                            'End Date',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.grey500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(_endDate),
                            style: AppTextStyles.titleSmall,
                          ),
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

            // ── Sum Assured ───────────────────────────────
            if (policy.maxSumAssured > 0) ...[
              Text('Coverage Amount', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              TextFormField(
                controller: _sumAssuredCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sum Assured (ETB)',
                  hintText: policy.sumAssuredDefault > 0
                      ? 'Default: ${AppFormatter.formatCurrency(policy.sumAssuredDefault)}'
                      : 'Enter amount',
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // optional
                  final parsed = double.tryParse(v);
                  if (parsed == null) return 'Enter a valid amount';
                  if (policy.maxSumAssured > 0 &&
                      parsed > policy.maxSumAssured) {
                    return 'Max allowed: ${AppFormatter.formatCurrency(policy.maxSumAssured)}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],

            // ── Notes ─────────────────────────────────────
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

            // ── Order summary ─────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Policy',
                    value: policy.title,
                  ),
                  if (selectedTier != null) ...[
                    _SummaryRow(
                      label: 'Plan',
                      value: selectedTier['termsDuration'] as String? ??
                          '${selectedTier['months']} months',
                    ),
                    _SummaryRow(
                      label: 'Period',
                      value:
                          '${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
                    ),
                    const Divider(height: 20),
                    _SummaryRow(
                      label: 'Premium',
                      value: AppFormatter.formatCurrency(
                          (selectedTier['price'] as num).toDouble()),
                      isTotal: true,
                    ),
                  ] else ...[
                    _SummaryRow(
                      label: 'Period',
                      value:
                          '${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
                    ),
                    const Divider(height: 20),
                    _SummaryRow(
                      label: 'Min Premium',
                      value: AppFormatter.formatCurrency(
                          policy.minPremium),
                      isTotal: true,
                    ),
                  ],
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

            // ── Submit ────────────────────────────────────
            AppButton(
              label: selectedTier != null
                  ? 'Submit Application — ${AppFormatter.formatCurrency((selectedTier['price'] as num).toDouble())}'
                  : 'Submit Application',
              onPressed: _isSubmitting ? null : () => _submit(policy),
              isLoading: _isSubmitting,
              leadingIcon: Icons.send_rounded,
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
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.grey500),
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
