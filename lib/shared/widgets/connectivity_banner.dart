import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../theme/app_colors.dart';

part 'connectivity_banner.g.dart';

@riverpod
Stream<List<ConnectivityResult>> connectivityStream(ConnectivityStreamRef ref) {
  return Connectivity().onConnectivityChanged;
}

/// Shows a banner at the top when the device is offline
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);

    return connectivityAsync.when(
      data: (results) {
        final isOffline = results.every((r) => r == ConnectivityResult.none);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isOffline
              ? Container(
                  key: const ValueKey('offline'),
                  width: double.infinity,
                  color: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'common.offline'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('online')),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
