import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/payments_provider.dart';

class PaymentDetailPage extends ConsumerWidget {
  final int paymentId;
  const PaymentDetailPage({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(paymentByIdProvider(paymentId));
    final uploadState = ref.watch(uploadReceiptProvider);

    return Scaffold(
      appBar: AppBar(title: Text('payments.payment_details'.tr())),
      body: paymentAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (payment) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              AppCard(
                gradient: AppColors.successGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppFormatter.formatCurrency(payment.amount),
                          style: AppTextStyles.displayMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        StatusChip.paymentStatus(payment.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      payment.policyTitle ?? 'Payment',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Details', style: AppTextStyles.titleMedium),
                    const Divider(height: 20),
                    _Row(label: 'payments.payment_date'.tr(),
                        value: AppFormatter.formatDate(
                          AppFormatter.parseDate(payment.paymentDate),
                        )),
                    _Row(label: 'payments.payment_type'.tr(),
                        value: payment.paymentType ?? '—'),
                    if (payment.transactionId != null)
                      _Row(
                        label: 'payments.transaction_id'.tr(),
                        value: payment.transactionId!,
                      ),
                    if (payment.notes != null && payment.notes!.isNotEmpty)
                      _Row(label: 'common.notes'.tr(), value: payment.notes!),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Receipt section
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('payments.receipt'.tr(), style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    if (payment.receiptFile != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Text('Receipt uploaded',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.success,
                                )),
                          ],
                        ),
                      )
                    else
                      AppButton(
                        label: 'payments.upload_receipt'.tr(),
                        onPressed: () => _uploadReceipt(context, ref, payment),
                        isLoading: uploadState.isLoading,
                        variant: AppButtonVariant.outlined,
                        leadingIcon: Icons.upload_rounded,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadReceipt(
    BuildContext context,
    WidgetRef ref,
    dynamic payment,
  ) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final success = await ref.read(uploadReceiptProvider.notifier).upload(
          insuranceId: payment.insuranceId,
          paymentId: payment.id,
          filePath: file.path,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Receipt uploaded!' : 'Upload failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
