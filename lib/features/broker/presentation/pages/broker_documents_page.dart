import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/models/broker_models.dart';
import '../providers/broker_providers.dart';
import '_broker_shared.dart';

// ╔══════════════════════════════════════════════════════════╗
// ║  Broker – Documents                                      ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerDocumentsPage extends ConsumerWidget {
  const BrokerDocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(brokerDocumentsProvider);

    return BrokerSubScaffold(
      title: 'Documents',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => ref.invalidate(brokerDocumentsProvider),
        ),
      ],
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.error)),
        ),
        data: (list) => list.isEmpty
            ? const EmptyView(
                title: 'No documents available',
                icon: Icons.folder_open_rounded)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, i) =>
                    _DocumentCard(item: list[i], index: i),
              ),
      ),
    );
  }
}

// ── Document Card (all payload fields) ───────────────────

class _DocumentCard extends StatelessWidget {
  final BrokerDocumentModel item;
  final int index;
  const _DocumentCard({required this.item, required this.index});

  IconData get _icon => switch (item.type.toUpperCase()) {
        'AGREEMENT' => Icons.handshake_rounded,
        'ENDORSEMENT' => Icons.edit_document,
        'KYC' => Icons.badge_rounded,
        'LICENSE' => Icons.card_membership_rounded,
        'POLICY' => Icons.shield_rounded,
        _ => Icons.description_rounded,
      };

  Color get _typeColor => switch (item.type.toUpperCase()) {
        'AGREEMENT' => AppColors.success,
        'ENDORSEMENT' => const Color(0xFF8B5CF6),
        'KYC' => AppColors.accent,
        'LICENSE' => AppColors.primary,
        _ => AppColors.grey600,
      };

  Color get _typeBg => switch (item.type.toUpperCase()) {
        'AGREEMENT' => AppColors.successLight,
        'ENDORSEMENT' => const Color(0xFFF3E8FF),
        'KYC' => AppColors.accentContainer,
        'LICENSE' => AppColors.primaryContainer,
        _ => AppColors.grey100,
      };

  @override
  Widget build(BuildContext context) {
    final canOpen = item.filePath.isNotEmpty;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: canOpen
          ? () async {
              final url = Uri.parse(
                  '${AppConstants.fileBaseUrl}/${item.filePath}');
              if (await canLaunchUrl(url)) launchUrl(url);
            }
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Type icon ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _typeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, size: 24, color: _typeColor),
          ),
          const SizedBox(width: 14),

          // ── Content ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.type,
                          style: AppTextStyles.titleSmall,
                          overflow: TextOverflow.ellipsis),
                    ),
                    StatusChip.documentStatus(item.status),
                  ],
                ),
                const SizedBox(height: 4),

                // Reference (from payload: reference)
                Text(
                  item.reference.isEmpty
                      ? 'No reference'
                      : 'Ref: ${item.reference}',
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // ID + Created
                Row(
                  children: [
                    BrokerInfoPill(
                        icon: Icons.tag_rounded,
                        label: 'ID',
                        value: '${item.id}'),
                    const SizedBox(width: 12),
                    BrokerInfoPill(
                        icon: Icons.access_time_rounded,
                        label: 'Added',
                        value: item.createdAt.split('T').first),
                  ],
                ),

                // File path indicator + open CTA
                if (item.filePath.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.open_in_new_rounded,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Tap to open document',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.link_off_rounded,
                          size: 13, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text('No file attached',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.grey400)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index))
        .slideX(begin: 0.05, curve: Curves.easeOut);
  }
}
