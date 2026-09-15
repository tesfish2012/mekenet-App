import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/injectable_config.dart';
import 'core/config/router.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/app_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize Firebase (optional — wrap in try/catch for dev environments)
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured yet — safe to ignore in development
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('am')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: MekenetinsuranceApp(),
      ),
    ),
  );
}

class MekenetinsuranceApp extends ConsumerWidget {
  const MekenetinsuranceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    AppTextStyles.brightness = _resolveBrightness(themeMode);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Mekenet Insurance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _resolveThemeMode(themeMode),
          routerConfig: router,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (context, child) {
            // Prevent text scaling beyond 1.2x for layout safety
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  ThemeMode _resolveThemeMode(String mode) {
    switch (mode) {
      case 'dark': return ThemeMode.dark;
      case 'light': return ThemeMode.light;
      default: return ThemeMode.system;
    }
  }

  Brightness _resolveBrightness(String mode) {
    switch (_resolveThemeMode(mode)) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.system:
        final platform = WidgetsBinding.instance.platformDispatcher;
        return platform.platformBrightness;
    }
  }
}
