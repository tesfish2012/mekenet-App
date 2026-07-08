import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/payments_provider.dart';
import '../../data/models/payment_model.dart';

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(allPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('payments.payment_history'.tr())),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allPaymentsProvider),
        color: AppColors.primary,
        child: paymentsAsync.when(
          loading: () => const ShimmerList(itemHeight: 90),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(allPaymentsProvider),
          ),
          data: (payments) => payments.isEmpty
              ? EmptyView(
                  title: 'payments.no_payments'.tr(),
                  subtitle: 'Your payment history will appear here.',
                  icon: Icons.receipt_long_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _PaymentCard(
                    payment: payments[index],
                    index: index,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final int index;

  const _PaymentCard({required this.payment, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/payments/${payment.id}'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payment_rounded,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.policyTitle ?? 'Payment #${payment.id}',
                  style: AppTextStyles.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatter.formatDate(
                    AppFormatter.parseDate(payment.paymentDate),
                  ),
                  style: AppTextStyles.bodySmall,
                ),
                if (payment.paymentType != null)
                  Text(
                    payment.paymentType!,
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatter.formatCurrency(payment.amount),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              StatusChip.paymentStatus(payment.status),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.05);
  }
}
