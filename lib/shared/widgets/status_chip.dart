import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Visual status badge used for policy, claim, payment statuses
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final double fontSize;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
    this.fontSize = 11,
  });

  factory StatusChip.policyStatus(String status) {
    final (color, bg) = _policyColors(status);
    return StatusChip(label: _capitalize(status), color: color, bgColor: bg);
  }

  factory StatusChip.claimStatus(String status) {
    final (color, bg) = _claimColors(status);
    return StatusChip(label: _formatStatus(status), color: color, bgColor: bg);
  }

  factory StatusChip.paymentStatus(String status) {
    final (color, bg) = _paymentColors(status);
    return StatusChip(label: _formatStatus(status), color: color, bgColor: bg);
  }

  factory StatusChip.documentStatus(String status) {
    final (color, bg) = _documentColors(status);
    return StatusChip(label: _capitalize(status), color: color, bgColor: bg);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNeutral = color == AppColors.grey500;
    final effectiveColor = isDark && isNeutral
      ? AppColors.darkTextSecondary
      : color;
    final effectiveBackground =
      isDark && bgColor == AppColors.grey100 ? AppColors.darkCard : bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: effectiveColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: effectiveColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color) _policyColors(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return (AppColors.statusActive, AppColors.successLight);
      case 'PENDING': return (AppColors.statusPending, AppColors.warningLight);
      case 'EXPIRED': return (AppColors.statusExpired, AppColors.errorLight);
      case 'CANCELLED': return (AppColors.statusCancelled, AppColors.grey100);
      case 'NEW': return (AppColors.statusNew, AppColors.infoLight);
      case 'IN_REVIEW':
      case 'CONFIRM': return (AppColors.statusReview, AppColors.accentContainer);
      default: return (AppColors.grey500, AppColors.grey100);
    }
  }

  static (Color, Color) _claimColors(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED': return (AppColors.claimSubmitted, AppColors.infoLight);
      case 'UNDER_REVIEW': return (AppColors.claimUnderReview, AppColors.warningLight);
      case 'APPROVED': return (AppColors.claimApproved, AppColors.successLight);
      case 'REJECTED': return (AppColors.claimRejected, AppColors.errorLight);
      case 'PAID': return (AppColors.claimPaid, AppColors.successLight);
      default: return (AppColors.grey500, AppColors.grey100);
    }
  }

  static (Color, Color) _paymentColors(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED': return (AppColors.success, AppColors.successLight);
      case 'PENDING': return (AppColors.warning, AppColors.warningLight);
      case 'REJECTED': return (AppColors.error, AppColors.errorLight);
      case 'IN_PROCESS': return (AppColors.info, AppColors.infoLight);
      default: return (AppColors.grey500, AppColors.grey100);
    }
  }

  static (Color, Color) _documentColors(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED': return (AppColors.success, AppColors.successLight);
      case 'PENDING': return (AppColors.warning, AppColors.warningLight);
      case 'REJECTED': return (AppColors.error, AppColors.errorLight);
      default: return (AppColors.grey500, AppColors.grey100);
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  static String _formatStatus(String s) =>
      s.replaceAll('_', ' ').split(' ').map(_capitalize).join(' ');
}
