import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/policies_provider.dart';
import '../providers/renewals_provider.dart';
import '../../data/models/policy_model.dart';
import '../../data/models/renewal_model.dart';

class PolicyDetailPage extends ConsumerWidget {
  final int policyId;
  const PolicyDetailPage({super.key, required this.policyId});

  void _showRenewalModal(BuildContext context, InsuranceModel insurance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RenewalBottomSheet(insurance: insurance),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insuranceAsync = ref.watch(insuranceByIdProvider(policyId));

    return Scaffold(
      appBar: AppBar(
        title: Text('policies.policy_details'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card_rounded),
            onPressed: () => context.push('/policies/$policyId/card'),
            tooltip: 'Digital Card',
          ),
        ],
      ),
      body: insuranceAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (insurance) {
          final isActive = insurance.status.toUpperCase() == 'ACTIVE';

          return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              AppCard(
                gradient: AppColors.primaryGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            insurance.policyTitle,
                            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      insurance.insuranceNumber,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusChip.policyStatus(insurance.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Policy Information', style: AppTextStyles.titleMedium),
                    const Divider(height: 20),
                    _DetailRow(label: 'policies.premium'.tr(),
                        value: AppFormatter.formatCurrency(insurance.premiumAmount)),
                    _DetailRow(label: 'policies.sum_assured'.tr(),
                        value: AppFormatter.formatCurrency(insurance.sumAssured)),
                    _DetailRow(label: 'policies.start_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(insurance.startDate))),
                    _DetailRow(label: 'policies.end_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(insurance.endDate))),
                    if (insurance.policyTerm != null)
                      _DetailRow(label: 'policies.policy_term'.tr(),
                          value: '${insurance.policyTerm} months'),
                    if (insurance.notes != null && insurance.notes!.isNotEmpty)
                      _DetailRow(label: 'common.notes'.tr(), value: insurance.notes!),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'policies.digital_card'.tr(),
                      onPressed: () => context.push('/policies/$policyId/card'),
                      variant: AppButtonVariant.outlined,
                      leadingIcon: Icons.credit_card_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'New Claim',
                      onPressed: isActive ? () => context.push('/claims/new?insuranceId=$policyId') : null,
                      leadingIcon: Icons.add_rounded,
                      isDisabled: !isActive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Request Renewal',
                onPressed: isActive ? () => _showRenewalModal(context, insurance) : null,
                leadingIcon: Icons.autorenew_rounded,
                variant: AppButtonVariant.primary,
                isDisabled: !isActive,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'claims.upload_documents'.tr(),
                onPressed: () => context.push('/documents'),
                variant: AppButtonVariant.outlined,
                leadingIcon: Icons.upload_file_rounded,
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.titleSmall),
          ),
        ],
      ),
    );
  }
}

// ── Renewal Bottom Sheet Modal ─────────────────────────────

class _RenewalBottomSheet extends ConsumerStatefulWidget {
  final InsuranceModel insurance;

  const _RenewalBottomSheet({required this.insurance});

  @override
  ConsumerState<_RenewalBottomSheet> createState() =>
      _RenewalBottomSheetState();
}

class _RenewalBottomSheetState extends ConsumerState<_RenewalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _premiumCtrl;
  late final TextEditingController _sumAssuredCtrl;
  late final TextEditingController _notesCtrl;
  int _termMonths = 12;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _premiumCtrl = TextEditingController(
      text: widget.insurance.premiumAmount > 0
          ? widget.insurance.premiumAmount.toStringAsFixed(2)
          : '',
    );
    _sumAssuredCtrl = TextEditingController(
      text: widget.insurance.sumAssured > 0
          ? widget.insurance.sumAssured.toStringAsFixed(2)
          : '',
    );
    _notesCtrl = TextEditingController();
    _termMonths = widget.insurance.policyTerm ?? 12;

    final parsedEnd = AppFormatter.parseDate(widget.insurance.endDate);
    if (parsedEnd != null && parsedEnd.isAfter(DateTime.now())) {
      _startDate = parsedEnd;
    } else {
      _startDate = DateTime.now();
    }
    _endDate = DateTime(
      _startDate.year,
      _startDate.month + _termMonths,
      _startDate.day,
    );
  }

  @override
  void dispose() {
    _premiumCtrl.dispose();
    _sumAssuredCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _updateTerm(int months) {
    setState(() {
      _termMonths = months;
      _endDate = DateTime(
        _startDate.year,
        _startDate.month + _termMonths,
        _startDate.day,
      );
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = DateTime(
          _startDate.year,
          _startDate.month + _termMonths,
          _startDate.day,
        );
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(_startDate)
          ? _endDate
          : _startDate.add(const Duration(days: 30)),
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final premium = double.tryParse(_premiumCtrl.text.trim()) ??
        widget.insurance.premiumAmount;
    final sumAssured = double.tryParse(_sumAssuredCtrl.text.trim()) ??
        widget.insurance.sumAssured;

    final req = NewRenewalRequest(
      insuranceId: widget.insurance.id,
      newPremiumAmount: premium,
      newSumAssured: sumAssured,
      newStartDate: _formatDate(_startDate),
      newEndDate: _formatDate(_endDate),
      newPolicyTerm: _termMonths,
      adminNotes:
          _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    final success = await ref.read(submitRenewalProvider.notifier).submit(req);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Renewal request submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to submit renewal. Please check the fields and try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(submitRenewalProvider).isLoading;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.autorenew_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Policy Renewal',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${widget.insurance.policyTitle} (${widget.insurance.insuranceNumber})',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Term Selection
              Text(
                'Select Renewal Term',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [6, 12, 24, 36].map((months) {
                  final isSel = _termMonths == months;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _updateTerm(months),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : AppColors.grey100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.grey300,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$months mos',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSel
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                              fontWeight:
                                  isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Premium Amount
              AppTextField(
                label: 'New Premium Amount',
                hint: '0.00',
                controller: _premiumCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter premium';
                  }
                  final val = double.tryParse(v.trim());
                  if (val == null || val <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Sum Assured
              AppTextField(
                label: 'New Sum Assured',
                hint: '0.00',
                controller: _sumAssuredCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.shield_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter sum assured';
                  }
                  final val = double.tryParse(v.trim());
                  if (val == null || val <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Dates Picker Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.grey500)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(_startDate),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('End Date',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.grey500)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.event_available_rounded,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(_endDate),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Notes
              AppTextField(
                label: 'Notes / Remarks (Optional)',
                hint: 'e.g., Requesting sum assured increase...',
                controller: _notesCtrl,
                maxLines: 2,
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 20),

              // Submit Button
              AppButton(
                label: 'Submit Renewal Request',
                onPressed: _submit,
                isLoading: isSubmitting,
                leadingIcon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

