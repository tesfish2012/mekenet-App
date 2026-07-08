import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/notifications_provider.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesProvider);
    final readIds = ref.watch(readNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.title'.tr()),
        actions: [
          noticesAsync.maybeWhen(
            data: (notices) => TextButton(
              onPressed: () => ref
                  .read(readNotificationsProvider.notifier)
                  .markAllRead(notices.map((n) => n.id).toList()),
              child: Text(
                'notifications.mark_all_read'.tr(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(noticesProvider),
        color: AppColors.primary,
        child: noticesAsync.when(
          loading: () => const ShimmerList(itemHeight: 80),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(noticesProvider),
          ),
          data: (notices) => notices.isEmpty
              ? EmptyView(
                  title: 'notifications.no_notifications'.tr(),
                  subtitle: 'You\'re all caught up!',
                  icon: Icons.notifications_none_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    final isRead = readIds.contains(notice.id);
                    return _NotificationCard(
                      notice: notice,
                      isRead: isRead,
                      index: index,
                      onTap: () => ref
                          .read(readNotificationsProvider.notifier)
                          .markRead(notice.id),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notice;
  final bool isRead;
  final int index;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notice,
    required this.isRead,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: isRead
          ? null
          : AppColors.primaryContainer.withOpacity(0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRead
                      ? AppColors.grey100
                      : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  size: 20,
                  color: isRead ? AppColors.grey400 : AppColors.primary,
                ),
              ),
              if (!isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 0,
                          spreadRadius: 1.5,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight:
                        isRead ? FontWeight.w500 : FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notice.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notice.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    AppFormatter.timeAgo(
                      AppFormatter.parseDate(notice.createdAt) ??
                          DateTime.now(),
                    ),
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
  }
}
