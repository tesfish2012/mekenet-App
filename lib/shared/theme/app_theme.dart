import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Material 3 light & dark themes for Mekenet Insurance
class AppTheme {
  AppTheme._();

  /// Wrap showDatePicker's builder with this to fix OK/Cancel button visibility.
  /// Usage: showDatePicker(builder: (ctx, child) => AppTheme.datePickerTheme(ctx, child))
  static Widget datePickerTheme(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        dialogTheme: theme.dialogTheme.copyWith(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      child: child!,
    );
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.accent,             // Gold as secondary
          onSecondary: Colors.white,
          secondaryContainer: AppColors.accentContainer,
          onSecondaryContainer: AppColors.accentDark,
          tertiary: AppColors.secondary,           // Navy as tertiary
          onTertiary: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceVariant: AppColors.lightBackground,
          background: AppColors.lightBackground,
          onBackground: AppColors.lightTextPrimary,
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorLight,
          outline: AppColors.lightBorder,
          shadow: Color(0x1A000000),
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: const Color(0x1A1A56DB),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          centerTitle: true,
          titleTextStyle: AppTextStyles.titleLarge.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.lightBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          labelStyle: AppTextStyles.bodyMedium,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.lightTextHint,
          ),
          errorStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
          prefixIconColor: AppColors.grey400,
          suffixIconColor: AppColors.grey400,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.primary),
            textStyle: AppTextStyles.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.button.copyWith(fontSize: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.grey100,
          selectedColor: AppColors.primaryContainer,
          labelStyle: AppTextStyles.labelMedium,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder,
          thickness: 1,
          space: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey400,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          indicatorColor: AppColors.primaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTextStyles.labelSmall;
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary);
            }
            return const IconThemeData(color: AppColors.grey400);
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.grey900,
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: StadiumBorder(),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.lightTextPrimary),
          displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.lightTextPrimary),
          headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.lightTextPrimary),
          headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.lightTextPrimary),
          headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.lightTextPrimary),
          titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.lightTextPrimary),
          titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.lightTextPrimary),
          titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.lightTextPrimary),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightTextPrimary),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.lightTextSecondary),
          labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.lightTextPrimary),
          labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.lightTextSecondary),
          labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.lightTextHint),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF1E3A8A),
          onPrimaryContainer: Colors.white,
          secondary: AppColors.accent,             // Gold as secondary
          onSecondary: AppColors.secondary,
          secondaryContainer: Color(0xFF3D2A00),
          onSecondaryContainer: AppColors.accentLight,
          tertiary: AppColors.primary,
          onTertiary: Colors.white,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceVariant: AppColors.darkCard,
          background: AppColors.darkBackground,
          onBackground: AppColors.darkTextPrimary,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.darkBorder,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          centerTitle: true,
          titleTextStyle: AppTextStyles.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkTextHint,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondaryLight,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.secondaryLight, width: 1.5),
            textStyle: AppTextStyles.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondaryLight,
            textStyle: AppTextStyles.button.copyWith(fontSize: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkCard,
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.darkTextPrimary),
          displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.darkTextPrimary),
          headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.darkTextPrimary),
          headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
          headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
          titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkTextPrimary),
          titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
          titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.darkTextPrimary),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
          labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.darkTextPrimary),
          labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.darkTextSecondary),
          labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.darkTextHint),
        ),
      );
}
