import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Handles Google Play in-app update checks.
///
/// Call [checkForUpdate] once from the splash or main screen.
/// - If an update is available and [flexible] is false → shows an
///   IMMEDIATE update flow (blocks the app until updated).
/// - If [flexible] is true → shows a flexible update banner; the
///   user can continue using the app and install later.
class AppUpdateService {
  AppUpdateService._();

  /// Check for update and trigger the appropriate flow.
  /// Safe to call on non-Android or when Play Store is unavailable
  /// — any error is silently caught.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool flexible = false,
  }) async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (flexible) {
          await InAppUpdate.startFlexibleUpdate();
          // Once downloaded, prompt the user to apply
          await InAppUpdate.completeFlexibleUpdate();
        } else {
          // IMMEDIATE: user must update before continuing
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (_) {
      // Silently ignore: device not supported, no Play Services, etc.
    }
  }
}
