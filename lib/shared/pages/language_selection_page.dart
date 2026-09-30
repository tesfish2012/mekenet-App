import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/injectable_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selected = 'en';

  @override
  void initState() {
    super.initState();
    // Pre-select the previously saved language
    final prefs = getIt<PreferencesService>();
    _selected = prefs.getLanguage();
  }

  Future<void> _continue() async {
    final prefs = getIt<PreferencesService>();
    await prefs.setLanguage(_selected);
    await prefs.setLanguageDone();
    if (!mounted) return;
    await context.setLocale(Locale(_selected));
    if (!mounted) return;
    // Navigate to onboarding if first time, otherwise login/dashboard
    if (!prefs.isOnboardingDone()) {
      context.go(AppConstants.routeOnboarding);
    } else {
      // Let the router redirect handle auth state
      context.go(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 36),

              // ── Ethiopian flag ──────────────────────────
              const _EthiopianFlag(size: 110)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.75, 0.75)),

              const SizedBox(height: 28),

              // ── Logo ────────────────────────────────────
              Image.asset(
                AppConstants.logoAsset,
                width: MediaQuery.of(context).size.width * 0.58,
                fit: BoxFit.contain,
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

              const SizedBox(height: 32),

              // ── Welcome title ────────────────────────────
              Text(
                'welcome.title'.tr(),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideY(begin: 0.2),

              const SizedBox(height: 10),

              Text(
                'welcome.subtitle'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTextStyles.textSecondaryColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

              const SizedBox(height: 40),

              // ── Language label ───────────────────────────
              Row(
                children: [
                  const Icon(Icons.language_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'welcome.choose_language'.tr(),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 14),

              // ── English option ───────────────────────────
              _LanguageTile(
                flag: '🇬🇧',
                label: 'English',
                sublabel: 'English',
                code: 'en',
                isSelected: _selected == 'en',
                onTap: () => setState(() => _selected = 'en'),
                delay: 500,
              ),

              const SizedBox(height: 12),

              // ── Amharic option ───────────────────────────
              _LanguageTile(
                flag: '🇪🇹',
                label: 'አማርኛ',
                sublabel: 'Amharic',
                code: 'am',
                isSelected: _selected == 'am',
                onTap: () => setState(() => _selected = 'am'),
                delay: 580,
              ),

              const SizedBox(height: 40),

              // ── Continue button ──────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'welcome.continue'.tr(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.15),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Language tile ─────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final String sublabel;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.code,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Flag emoji in a circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.08)
                    : AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppTextStyles.textPrimaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTextStyles.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.grey300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideY(begin: 0.1);
  }
}

// ── Ethiopian flag painter ────────────────────────────────

class _EthiopianFlag extends StatelessWidget {
  final double size;
  const _EthiopianFlag({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: _EthiopianFlagPainter(),
        ),
      ),
    );
  }
}

class _EthiopianFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripeH = size.height / 3;

    // Green stripe (top)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, stripeH),
      Paint()..color = const Color(0xFF078930),
    );
    // Yellow stripe (middle)
    canvas.drawRect(
      Rect.fromLTWH(0, stripeH, size.width, stripeH),
      Paint()..color = const Color(0xFFFCDD09),
    );
    // Red stripe (bottom)
    canvas.drawRect(
      Rect.fromLTWH(0, stripeH * 2, size.width, stripeH),
      Paint()..color = const Color(0xFFDA121A),
    );

    // Blue circle in center
    final center = Offset(size.width / 2, size.height / 2);
    final circleR = size.width * 0.28;
    canvas.drawCircle(
      center,
      circleR,
      Paint()..color = const Color(0xFF0F47AF),
    );

    // 5-pointed star in the blue circle
    _drawStar(canvas, center, circleR * 0.62, circleR * 0.26,
        Paint()..color = const Color(0xFFFCDD09));

    // Star rays (5 thin lines from center outward)
    final rayPaint = Paint()
      ..color = const Color(0xFFFCDD09)
      ..strokeWidth = size.width * 0.018
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / 5) * i;
      final rayEnd = Offset(
        center.dx + math.cos(angle) * circleR * 0.88,
        center.dy + math.sin(angle) * circleR * 0.88,
      );
      canvas.drawLine(center, rayEnd, rayPaint);
    }
  }

  void _drawStar(
      Canvas canvas, Offset center, double outerR, double innerR, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = -math.pi / 2 + (math.pi / 5) * i;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
