import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class _OnboardSlide {
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final List<Color> gradient;

  const _OnboardSlide({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.gradient,
  });
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentIndex = 0;

  final _slides = const [
    _OnboardSlide(
      titleKey: 'onboarding.slide1_title',
      subtitleKey: 'onboarding.slide1_subtitle',
      icon: Icons.shield_rounded,
      gradient: AppColors.primaryGradient,
    ),
    _OnboardSlide(
      titleKey: 'onboarding.slide2_title',
      subtitleKey: 'onboarding.slide2_subtitle',
      icon: Icons.assignment_turned_in_rounded,
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
    ),
    _OnboardSlide(
      titleKey: 'onboarding.slide3_title',
      subtitleKey: 'onboarding.slide3_subtitle',
      icon: Icons.lock_rounded,
      gradient: AppColors.cardGradient,
    ),
  ];

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    getIt<PreferencesService>().setOnboardingDone();
    context.go(AppConstants.routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: _slides.length,
            itemBuilder: (context, index) => _SlidePage(slide: _slides[index]),
          ),
          // Skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'onboarding.skip'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentIndex ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: _currentIndex == _slides.length - 1
                          ? 'onboarding.get_started'.tr()
                          : 'common.next'.tr(),
                      onPressed: _onNext,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _OnboardSlide slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradient,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: Colors.white),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.7, 0.7)),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              slide.titleKey.tr(),
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              slide.subtitleKey.tr(),
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.85),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
          ),
        ],
      ),
    );
  }
}
