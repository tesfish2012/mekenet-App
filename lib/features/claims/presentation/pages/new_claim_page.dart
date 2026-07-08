import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/claims_provider.dart';
import '../../../policies/presentation/providers/policies_provider.dart';

class NewClaimPage extends ConsumerStatefulWidget {
  final int? insuranceId;
  const NewClaimPage({super.key, this.insuranceId});

  @override
  ConsumerState<NewClaimPage> createState() => _NewClaimPageState();
}

class _NewClaimPageState extends ConsumerState<NewClaimPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _incidentDate;
  int? _selectedInsuranceId;

  @override
  void initState() {
    super.initState();
    _selectedInsuranceId = widget.insuranceId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _incidentDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the incident date')),
      );
      return;
    }
    if (_selectedInsuranceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a policy')),
      );
      return;
    }

    final success = await ref.read(submitClaimProvider.notifier).submit(
          insuranceId: _selectedInsuranceId!,
          incidentDate: AppFormatter.toApiDate(_incidentDate!),
          claimAmount: double.tryParse(_amountCtrl.text) ?? 0,
          description: _descCtrl.text.trim(),
        );

    if (success && mounted) {
      ref.invalidate(myClaimsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim submitted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit claim. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitClaimProvider);
    final isLoading = submitState.isLoading;
    final insurancesAsync = ref.watch(myInsurancesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('claims.new_claim'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Submit a New Claim', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Fill in the details below to submit your claim.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Policy selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Policy', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 6),
                  insurancesAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading policies'),
                    data: (insurances) => DropdownButtonFormField<int>(
                      value: _selectedInsuranceId,
                      hint: const Text('Choose a policy'),
                      decoration: const InputDecoration(),
                      items: insurances
                          .where((i) => i.status == 'ACTIVE')
                          .map((i) => DropdownMenuItem<int>(
                                value: i.id,
                                child: Text(
                                  '${i.policyTitle} • ${i.insuranceNumber}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedInsuranceId = v),
                      validator: (v) => v == null ? 'Please select a policy' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Incident Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('claims.incident_date'.tr(), style: AppTextStyles.labelLarge),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.grey50,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.grey400),
                          const SizedBox(width: 10),
                          Text(
                            _incidentDate != null
                                ? AppFormatter.formatDate(_incidentDate)
                                : 'Select incident date',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: _incidentDate != null ? null : AppColors.lightTextHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'claims.claim_amount'.tr(),
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money_rounded,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: Validators.amount,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'claims.description'.tr(),
                controller: _descCtrl,
                maxLines: 5,
                validator: (v) => Validators.minLength(v, 20, fieldName: 'Description'),
                hint: 'Describe what happened (min 20 characters)...',
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'claims.submit_claim'.tr(),
                onPressed: _submit,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
