/// Shared scaffold + small widgets reused by all broker sub-pages.
/// Private to the broker feature — not exported outside.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

// ── Currency helper ───────────────────────────────────────

final _currencyFmt = NumberFormat.currency(
  locale: 'en_ET',
  symbol: 'ETB ',
  decimalDigits: 0,
);

String brokerFmtCurrency(double v) => _currencyFmt.format(v);

// ── Shared Scaffold ───────────────────────────────────────

class BrokerSubScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? fab;
  final Widget? bottomSheet;

  const BrokerSubScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.fab,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: fab,
      bottomSheet: bottomSheet,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 14, right: 16),
              title: Text(
                title,
                style: AppTextStyles.titleMedium
                    .copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.darkGradient,
                  ),
                ),
              ),
            ),
            actions: actions,
          ),
        ],
        body: body,
      ),
    );
  }
}

// ── Info Pill ─────────────────────────────────────────────

class BrokerInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const BrokerInfoPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.grey500),
        const SizedBox(width: 4),
        Text('$label: ',
            style: AppTextStyles.caption),
        Flexible(
          child: Text(
            value.isEmpty ? '—' : value,
            style: AppTextStyles.caption
                .copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Read-only row ─────────────────────────────────────────

class BrokerDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const BrokerDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.grey500),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────

class BrokerSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final Widget? trailing;

  const BrokerSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(icon, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(title, style: AppTextStyles.titleSmall),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Status color helpers ──────────────────────────────────

Color brokerPolicyStatusColor(String s) =>
    switch (s.toUpperCase()) {
      'ACTIVE' => AppColors.success,
      'PENDING' || 'PENDING_PAYMENT' => AppColors.warning,
      'EXPIRED' => AppColors.error,
      'CANCELLED' => AppColors.grey500,
      _ => AppColors.primary,
    };

Color brokerPolicyStatusBg(String s) =>
    switch (s.toUpperCase()) {
      'ACTIVE' => AppColors.successLight,
      'PENDING' || 'PENDING_PAYMENT' => AppColors.warningLight,
      'EXPIRED' => AppColors.errorLight,
      _ => AppColors.primaryContainer,
    };

Color brokerClaimStatusColor(String s) =>
    switch (s.toUpperCase()) {
      'SUBMITTED' => AppColors.primary,
      'UNDER_REVIEW' => AppColors.warning,
      'APPROVED' => AppColors.success,
      'REJECTED' => AppColors.error,
      'PAID' => AppColors.claimPaid,
      _ => AppColors.grey500,
    };

Color brokerClaimStatusBg(String s) =>
    switch (s.toUpperCase()) {
      'SUBMITTED' => AppColors.primaryContainer,
      'UNDER_REVIEW' => AppColors.warningLight,
      'APPROVED' => AppColors.successLight,
      'REJECTED' => AppColors.errorLight,
      'PAID' => AppColors.successLight,
      _ => AppColors.grey100,
    };
