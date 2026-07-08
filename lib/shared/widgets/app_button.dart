import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger }

/// Enterprise-grade button with loading, icon, and disabled states
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    switch (variant) {
      case AppButtonVariant.primary:
        return _buildElevated(context, isEnabled);
      case AppButtonVariant.secondary:
        return _buildFilled(context, isEnabled);
      case AppButtonVariant.outlined:
        return _buildOutlined(context, isEnabled);
      case AppButtonVariant.text:
        return _buildText(context, isEnabled);
      case AppButtonVariant.danger:
        return _buildDanger(context, isEnabled);
    }
  }

  Widget _buildElevated(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor: AppColors.grey200,
          disabledForegroundColor: AppColors.grey400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: _buildContent(
          color: isEnabled ? (foregroundColor ?? Colors.white) : AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildFilled(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.secondary,
          disabledBackgroundColor: AppColors.grey200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildContent(color: Colors.white),
      ),
    );
  }

  Widget _buildOutlined(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: backgroundColor ?? AppColors.primary,
          side: BorderSide(
            color: isEnabled ? (backgroundColor ?? AppColors.primary) : AppColors.grey300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildContent(
          color: isEnabled ? (backgroundColor ?? AppColors.primary) : AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, bool isEnabled) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: Size(width ?? 0, height),
      ),
      child: _buildContent(
        color: isEnabled ? AppColors.primary : AppColors.grey400,
      ),
    );
  }

  Widget _buildDanger(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.errorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: _buildContent(color: Colors.white),
      ),
    );
  }

  Widget _buildContent({required Color color}) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18, color: color),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTextStyles.button.copyWith(color: color)),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 18, color: color),
        ],
      ],
    );
  }
}
